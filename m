From: "Johnson, Chester F" <chester.f.johnson@intel.com>
Subject: RE: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 13:35:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7E713DB94F47914DB5AAB80DE8EEA87501539903@fmsmsx410.fm.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <ruddk@us.ibm.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Andi Kleen" <ak@suse.de>, "Nivedita Singhvi" <niv@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>From a corporate network perspective there are a couple of options that
can temporarily work around the problem. As an example, support for
jumbo frames on Ethernet IP-Sec interfaces. This would require some
hardware replacement, but GigE generally supports this. On the other
hand, I'm not sure I want to comprehend IP-Sec at GigE line rates.

We are pretty early in deploying diff-serv compliant QoS at this scale.
We are also one of few companies that mandate encrypted private WAN
links (Only the paranoid survive). As we look forward, we would expect
more frequent appearance of this behavior at other companies. 

All that said, an evolutionary roll-out is OK. Knowing that there is a
target release that would resolve the issue gives us something to look
forward to. It may also be a good idea to submit some clarification in
the relevant RFCs.

chet




-----Original Message-----
From: Andi Kleen [mailto:ak@suse.de] 
Sent: Wednesday, December 10, 2003 12:55 PM
To: Nivedita Singhvi
Cc: ruddk@us.ibm.com; netdev@oss.sgi.com; Johnson, Chester F
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)


On Wed, 10 Dec 2003 12:30:39 -0800
Nivedita Singhvi <niv@us.ibm.com> wrote:
 
> > I don't think the network users will be very happy if you require 
> > changing all end hosts this way. How about the following hack? For 
> > DF=1 packets the ipid field is useless. When you rewrite the TOS to 
> > DSCP save the old TOS in the ipid field.  When you see an ICMP 
> > fragment required message with the right DSCP on the router restore 
> > the old TOS from the ipid field.
> 
> Wouldnt this require changes at the both ends, router and host? How 
> would we sync?

Only the router would need to change (and rewrite ICMP messages, which
is a 
bit nasty, but then compatibility is not always fun) 

-Andi

P.S.: I am not opposed to fixing linux for this, just I have my doubts
that fixing all end hosts is a practical solution for the problem.
