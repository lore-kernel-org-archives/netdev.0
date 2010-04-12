From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rps: add flow director support
Date: Mon, 12 Apr 2010 22:27:04 +0800
Message-ID: <u2m412e6f7f1004120727ga219ab9dr75ee522fba6f63c6@mail.gmail.com>
References: <1271022140-3917-1-git-send-email-xiaosuo@gmail.com>
	<z2o65634d661004120634h8336409er33af1fb75c2a9d1b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:59606 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973Ab0DLO1y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 10:27:54 -0400
Received: by pva18 with SMTP id 18so3106177pva.19
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 07:27:54 -0700 (PDT)
In-Reply-To: <z2o65634d661004120634h8336409er33af1fb75c2a9d1b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 12, 2010 at 9:34 PM, Tom Herbert <therbert@google.com> wrot=
e:
> On Sun, Apr 11, 2010 at 2:42 PM, Changli Gao <xiaosuo@gmail.com> wrot=
e:
>> add rps flow director support
>>
>> with rps flow director, users can do weighted packet dispatching amo=
ng CPUs.
>> For example, CPU0:CPU1 is 1:3 for eth0's rx-0:
>>
> "Flow director" is a misnomer here in that it has no per flow
> awareness, that is what RFS provides. =C2=A0Please use a different na=
me.

=46low here is a bundle of flow, not the original meaning. How about
"rps_buckets" and "rps_bucket_x"?

>
>> =C2=A0localhost linux # echo 4 > /sys/class/net/eth0/queues/rx-0/rps=
_flows
>> =C2=A0localhost linux # echo 0 > /sys/class/net/eth0/queues/rx-0/rps=
_flow_0
>> =C2=A0localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps=
_flow_1
>> =C2=A0localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps=
_flow_2
>> =C2=A0localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps=
_flow_3
>>
> It might be better to put this in its own directory

I have thought that before, but since they control the same data in
kernel as rps_cpus does, I put them in the same directory.

> and also do it per
> CPU instead of hash entry. =C2=A0This should result in a lot fewer en=
tries
> and I'm not sure how you would deal with holes in the hash table for
> unspecified entries. =C2=A0Also, it would be nice not to have to spec=
ify a
> number of entries. =C2=A0Maybe something like:
>
> localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_cpu_ma=
p/0
> localhost linux # echo 3 > /sys/class/net/eth0/queues/rx-0/rps_cpu_ma=
p/1
>
> To specify CPU 0 with weight 1, CPU 1 with weight 3.
>

Your way is more simple and straightforward. My idea has it own advanta=
ge:
1. control the rate precision through rps_flows.
2. do dynamic weighted packet dispatching by migrating some flows from
some CPUs to other CPUs. During this operations, only the flows
migrated are affected, and OOO only occurs in these flows.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
