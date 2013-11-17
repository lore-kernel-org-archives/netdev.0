From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Sun, 17 Nov 2013 14:38:34 -0800
Message-ID: <1384727914.8604.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJZOPZ+jUanPW2mT_HiSWdvGfdRMHpX6vWyrboS3Zf_gH7rEgQ@mail.gmail.com>
	 <1384638027.8604.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuzkwVSetLKb0AK7U=iB5ArhAhs-0vx9cX+WeZ2Fz04kqg@mail.gmail.com>
	 <1384708847.8604.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuw1VUtafKVnBOKAy+rNyKDYnDsst8ygwqEtKX75w96Q-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:46708 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377Ab3KQWig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 17:38:36 -0500
Received: by mail-pb0-f45.google.com with SMTP id mc8so5874775pbc.4
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 14:38:36 -0800 (PST)
In-Reply-To: <CAMEtUuw1VUtafKVnBOKAy+rNyKDYnDsst8ygwqEtKX75w96Q-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-11-17 at 11:00 -0800, Alexei Starovoitov wrote:
> On Sun, Nov 17, 2013 at 9:20 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Sat, 2013-11-16 at 23:31 -0800, Alexei Starovoitov wrote:
> >
> >> In case of VMs sending gso packets over tap and tunnel in the host,
> >> ip_forward is not in the picture.
> >>
> >
> > I was specifically answering to #2 which should use ip forwarding, of
> > course. Note that my patch was a POC : We have many other places where
> > the typical MTU check is simply disabled as soon as skb is GSO.
> 
> I don't think #2 will do ip_forward either. veth goes into a bridge
> and vxlan just adds encap.

The point is : nothing really checks mtu for gso packets.

Same construct was copy/pasted everywhere. See br_dev_queue_push_xmit()
for another example.

In this particular case, I guess vxlan should generate the ICMP.

But really, its Sunday and I currently do not care ;)
