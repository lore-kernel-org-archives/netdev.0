From: Gary Spiess <Gary.Spiess@Intermec.com>
Subject: Re: [PATCH] natsemi: long cable, short cable
Date: Mon, 14 Feb 2005 22:35:34 -0600
Message-ID: <42117C16.8010800@Intermec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

I just read your message of Feb 10th, 2005 regarding the cable problems 
of natsemi.c.  My investigation started late last week.  On Feb 14th, I 
got serious and nailed it down.  I submitted a patch of my own without 
realizing there was other work in progress on the same issue.  Please 
consider replacing the patch you didn't like with mine.

What was happening with my DP83815D was that the TSTDAT value being read 
in the do_cable_magic function was near 0x1f, regardless of cable 
length.  The code that fixes short cable problems actually works for 
short cables, but messes up long ones.  The cable magic couldn't figure 
out the length of the cable and always applied the fix.  I went looking 
for the history of this patch on the Internet and found a DP83815 Linux 
driver written and maintained by National Semiconductor.  I was struck 
by the difference in the initialization sequences.  natsemi.c always 
applies the sequence documented for the DP83815B.  dp83815.c applies 
different sequences for chip revisions B, C, and D+.  I used the D 
initialization for my D chip, and again watched the values being 
returned from TSTDAT in do_cable magic.  A 1m cable returned something 
like 0xF8 and a 90m cable return something like 0xB8.  Now the register 
was returning a value like it must have done with previous revisions of 
the chip. The magic is properly applied in the proper situation.

Since there is no public documentation on these PHY manipulations, I 
minimized the 'fix' to the setting of the DSPCFG register.  If I only 
turn on the bit that makes the coefficient readable, do_cable_magic now 
appears to have the right information to decide the cable length 
automatically.

Ain't life great?

Gary

in reply to http://oss.sgi.com/archives/netdev/2005-02/msg00396.html

-- 
 oooooooooooooooooooooooooooooooooooooooooooooooooo
  Gary Spiess (Gary.Spiess@Intermec.com)
  MobileLan Wireless Products Group, Intermec Technology Corp
  voice: 319 369-3580  fax: 319 369-3804
