From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2 net-next] vxlan: Be liberal on receive and only
 require the I bit to be set
Date: Mon, 14 Jul 2014 08:46:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17271981@AcuExch.aculab.com>
References: <cover.1405097440.git.tgraf@suug.ch>
	<cc7b11d065475a303d4a12a34acfded4e830c313.1405097440.git.tgraf@suug.ch>
 <20140711124126.262c2876@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>,
	"nicolas.dichtel@6wind.com" <nicolas.dichtel@6wind.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"Pritesh Kothari (pritkoth)" <pritkoth@cisco.com>,
	Madhu Challa <challa@noironetworks.com>
To: 'Stephen Hemminger' <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42527 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751479AbaGNIrl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 04:47:41 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06588-09 for <netdev@vger.kernel.org>;
 Mon, 14 Jul 2014 09:47:32 +0100 (BST)
In-Reply-To: <20140711124126.262c2876@samsung-9>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger
> On Fri, 11 Jul 2014 18:59:49 +0200
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > @@ -1617,7 +1646,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
> >  	}
> >
> >  	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
> > -	vxh->vx_flags = htonl(VXLAN_FLAGS);
> > +	vxlan_flags(vxh) = VXLAN_FLAG_VNI;
> > +	vxh->vx_reserved1 = 0;
> > +	vxh->vx_reserved2 = 0;
> >  	vxh->vx_vni = vni;
> >
> 
> Okay, but initializing bitfields generates crappy code.
> Can we just alias and do one assignment.

If you write to all the bitfields gcc ought to manage to do a single write.
If it doesn't then all the bitfields should be ripped out :-)

	David
