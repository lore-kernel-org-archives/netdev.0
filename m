From: Eus <eus@member.fsf.org>
Subject: Memory alignment issue in a network protocol header
Date: Thu, 17 Apr 2008 20:08:41 -0700 (PDT)
Message-ID: <695248.45047.qm@web37605.mail.mud.yahoo.com>
Reply-To: eus@member.fsf.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37605.mail.mud.yahoo.com ([209.191.87.88]:42073 "HELO
	web37605.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753138AbYDRDIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 23:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ho!

I am implementing a networking protocol (http://sourceforge.net/projects/atn).
This networking protocol has the following header:

struct clnphdr {
	__u8 cnf_proto_id;
	__u8 cnf_hdr_len;
	__u8 cnf_vers;
	__u8 cnf_ttl;
	__u8 cnf_flag;
	__be16 cnf_seglen;
	__u8 cnf_cksum_msb;
	__u8 cnf_cksum_lsb;
	__u8 dest_len;
	__u8 dest_addr[20];
	__u8 src_len;
	__u8 src_addr[20];
	__u8 next_part[0];
};

Because of 4-byte memory alignment in i386, there will be 1-byte padding in
`cnf_seglen'.

This alignment prevents me from doing:
        struct clnphdr clnph = (struct clnphdr *) skb->nh.raw;
because ntohs(clnph->cnf_seglen) will return the wrong result.

The wrong result will occur because in `skb->nh.raw' the data is packed (no
hole).

The easiest solution will be to put __attribute__((packed)) in the definition of
struct clnphdr, but this will incur performance penalty, won't this?

So, how should I handle this problem in the proper way as to permit portability
to 64-bit machines as well?

Thank you very much.

Best regards,
Eus


      ____________________________________________________________________________________
Be a better friend, newshound, and 
know-it-all with Yahoo! Mobile.  Try it now.  http://mobile.yahoo.com/;_ylt=Ahu06i62sR8HDtDypao8Wcj9tAcJ
