From: "Olson, John C" <John.Olson@nationalcity.com>
Subject: system hang under remove security
Date: Wed, 14 Aug 2002 11:46:41 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <EDF560E8C1E4A0439EA7828DDC95AFDF01839B89@nt-cleopsapp44.ntl-city.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

Hello,

Have been working with Andrey Savochkin on a problem that I have been
experiencing with the 2.4.16 kernel and he suggested that I contact you to
see if you had experience with it.  

The key points are:
*	my system hung (didn't respond to keyboard, remote and so on) when I
ran remote network scanner (nessus - specifically udp scans for mstream and
trinoo although it fails for more than that)
*	I had all my services disabled (see netstat output below)
*	I've tried it with eepro100 and 3com card, with the same result
*	my kernel is 2.4.16 (SuSE provided for 7.3 professional)
*	Running on a Compaq ML370 with a 4200 controller

Here is a listing of my netstat -a:
	Active Internet connections (servers and established)
	Proto Recv-Q Send-Q Local Address           Foreign Address
State
	raw        0      0 *:raw                   *:*
7
	Active UNIX domain sockets (servers and established)
	Proto RefCnt Flags       Type       State         I-Node Path
	unix  6      [ ]         DGRAM                    620    /dev/log
	unix  3      [ ]         STREAM     CONNECTED     3352
	unix  3      [ ]         STREAM     CONNECTED     3351
	unix  2      [ ]         DGRAM                    3309
	unix  2      [ ]         DGRAM                    1207
	unix  2      [ ]         DGRAM                    1058
	unix  2      [ ]         DGRAM                    826
Here is a listing of lsmod:
	Module                  Size  Used by
	af_packet              12976   1  (autoclean)
	3c59x                  22240   1  (autoclean)
	pci-scan                3440   1  (autoclean) [3c59x]
	lvm-mod                45440  13  (autoclean)
	reiserfs              153520   8
	ncr53c8xx              51856   0  (unused)
	cpqarray               16208   4

The question: are there known vulnerabilities of this kind?  It seems like I
have (in my mind) narrowed this problem down to either a kernel or IP stack
problem.  Any help would be very much appreciated.

Thanks,
John

-----Original Message-----
From: Andrey Savochkin [mailto:saw@saw.sw.com.sg]
Sent: Wednesday, August 14, 2002 10:43 AM
To: Olson, John C
Subject: Re: 2.4.16 freezed up with eepro100 module


On Wed, Aug 14, 2002 at 10:24:39AM -0400, Olson, John C wrote:
> BTW - just tried the same thing with sshd turned off as well (i.e. only
> thing listening was raw) and it still crashed.  Doesn't that mean that the
> only things left to check are the ip stack, kernel and driver?  Since I've
> gone through multiple drivers and cards, shouldn't that take out the
driver
> leaving the stack and kernel?

You've done it already, by trying 2 different drivers: eepro100 and 3com,
right?  So, you've eliminated the driver.

I think, it's the time to ask other kernel people,
Alan Cox <alan@lxorguk.ukuu.org.uk> or the mailing list netdev@oss.sgi.com.

The key points are:
 - your system hung (didn't respond to keyboard and so on) when
   you ran remote network scanner, doing nessus or whatever attacks
 - you had all your services disabled (provide netstat output)
 - you've tried it with eepro100 and 3com card, with the same result
 - your kernel is 2.4.16 (add whether it's a mainstream or redhat kernel)
The question: are there known vulnerabilities of this kind?

And pick up a reasonable subject, like "system hang under remove security
scan" :-)

	Andrey
