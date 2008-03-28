From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Fri, 28 Mar 2008 08:46:20 +0100
Message-ID: <47ECA24C.10803@cosmosbay.com>
References: <47EBC641.8040405@cosmosbay.com> <20080327183745.M9944@visp.net.lb> <47EBEDC9.6080100@cosmosbay.com> <20080327.150308.205829519.davem@davemloft.net> <20080328052543.M60286@visp.net.lb> <47EC8701.1080604@cosmosbay.com> <20080328073854.M73368@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080328073854.M73368@visp.net.lb>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys Fedoryshchenko a =C3=A9crit :
> Already patched and tested, it doesn't change anything.
>
>  =20

We still leak dsts somewhere.

You could try git bisect, or try to patch net/core/dst.c so that=20
dst_gc_task() (line 83) displays
route informations for say 10 first entries found in the dst_busy_list
(refcnt, interface, source IP, dest IP, things like that) that could=20
ring a bell given your netfilter rules or network conf.
>
>> Maybe you are a litle bit too fast for "ip route flush cache" :)
>>
>> It used to work like that : schedule a timer to start a flush in=20
>> about 2 seconds. A flush meaning : scan the whole table and delete=20
>> all entries.
>>
>> On machines with 4 millions dst entries, this was using too much=20
>> time and eventually crashing.
>>
>> On recent kernels, each rtable entry has a special field named=20
>> rt_genid, so that "ip route flush cache" doesnt have to scan the=20
>> whole table, but only change the global genid. rtables entries will=20
>> be deleted later, when their rt_genid is found to be different than=20
>> the global genid.
>>
>> Please try the patch that was suggested yesterday, as it is probably=
=20
>> the cure your router needs.
>>
>> http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-
>>    =20
> 2.6.git;a=3Dcommitdiff;h=3D7c0ecc4c4f8fd90988aab8a95297b9c0038b6160
>  =20




--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
