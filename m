From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Mon, 18 Nov 2013 14:57:23 -0800
Message-ID: <CAEP_g=9hg3zWGUqw4mRdtGu7=aR7-y5bRisWDgRgUfHpio-akw@mail.gmail.com>
References: <CAJZOPZ+jUanPW2mT_HiSWdvGfdRMHpX6vWyrboS3Zf_gH7rEgQ@mail.gmail.com>
 <1384638027.8604.22.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAMEtUuzkwVSetLKb0AK7U=iB5ArhAhs-0vx9cX+WeZ2Fz04kqg@mail.gmail.com> <OFF76C3619.82D931F7-ON85257C27.005F4843-85257C27.006270D6@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:36623 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751460Ab3KRW5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 17:57:44 -0500
Received: by mail-ie0-f174.google.com with SMTP id at1so3923724iec.19
        for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 14:57:43 -0800 (PST)
In-Reply-To: <OFF76C3619.82D931F7-ON85257C27.005F4843-85257C27.006270D6@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 18, 2013 at 9:55 AM, David Stevens <dlstevens@us.ibm.com> wrote:
> My idea for solving this ICMP issue is to forge an ICMP2BIG with the
> source address of the destination and send it back to the originating VM
> directly. It's complicated a bit because we don't want to use icmp_send()
> on the host, which will go through host routing tables when we don't
> necessarily have an IP address or routing for the bridged domain. So, to
> do this, we really should just have a stand-alone icmp sender for use by
> tunnel endpoints. But if we do this, the VM can get the correct gso_size
> accounting for the tunnel overhead too, although it's abusing PMTUD a bit
> since it doesn't ordinarily apply to hosts on the same L2 network.

OVS used to do exactly this in its tunnel implementation. It worked
fairly well although we ended up taking it out a while back since it
was a little offensive due to the need to forge addresses and have
essentially a parallel stub of an IP stack.
