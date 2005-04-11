From: linux lover <linux_lover2004@yahoo.com>
Subject: Why skbuff.h different for 2.4 and 2.6 kernels?
Date: Mon, 11 Apr 2005 09:37:52 -0700 (PDT)
Message-ID: <20050411163753.20149.qmail@web52210.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
1) In 2.4 kernel series skbuff.h has following unions
for each TCP/IP layer.
       /*Transport Layer*/
      union
	{
		struct tcphdr	*th;
		struct udphdr	*uh;
		struct icmphdr	*icmph;
		struct igmphdr	*igmph;
		struct iphdr	*ipiph;
                struct spxhdr	*spxh;
		unsigned char	*raw;
	} h;

	/* Network layer header */
	union
	{
		struct iphdr	*iph;
		struct ipv6hdr	*ipv6h;
		struct arphdr	*arph;
		struct ipxhdr	*ipxh;
		unsigned char	*raw;
	} nh;

	/* Link layer header */
	union 
	{	
	  	struct ethhdr	*ethernet;
	  	unsigned char 	*raw;
	} mac;

AND In 2.6 kernel series skbuff.h has following unions
for each TCP/IP layer.
	union {
		struct tcphdr	*th;
		struct udphdr	*uh;
		struct icmphdr	*icmph;
		struct igmphdr	*igmph;
		struct iphdr	*ipiph;
		struct ipv6hdr	*ipv6h;
		unsigned char	*raw;
	} h;

	union {
		struct iphdr	*iph;
		struct ipv6hdr	*ipv6h;
		struct arphdr	*arph;
		unsigned char	*raw;
	} nh;

	union {
	  	unsigned char 	*raw;
	} mac;

 why mac union in 2.6 not have ethernet header? Also
spxhdr and ipxhdr structures are removed from nh and h
unions.

2) Why header structures for ipcomp,eh,esp(IPSEC) not
included in skbuff.h?
 Then how can skbuff adds/removes those headers in
skbuff? 

regards,
linux_lover

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
