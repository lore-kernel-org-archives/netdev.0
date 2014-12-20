From: Andre Tomt <andre@tomt.net>
Subject: Re: REGRESSION in nfnetlink on 3.18.x (bisected)
Date: Sun, 21 Dec 2014 00:51:55 +0100
Message-ID: <54960B9B.5030005@tomt.net>
References: <5496075F.3060204@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <5496075F.3060204@tomt.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Copying change author

On 21. des. 2014 00:33, Andre Tomt wrote:
> On at least Ubuntu 14.04 LTS and Ubuntu 14.10 "conntrack -E" has started
> failing with Linux 3.18.x. conntrack -L still works.
>
> 14.04 and 14.10 ships conntrack-utils version 1.4.1, but 1.4.2 does not
> work either.
>
> It fails with:
>> # conntrack -E
>> conntrack v1.4.2 (conntrack-tools): Can't open handler
>
> strace shows:
>> bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
>> getsockname(3, {sa_family=AF_NETLINK, pid=14092, groups=00000000},
>> [12]) = 0
>> bind(3, {sa_family=AF_NETLINK, pid=14092, groups=00000007}, 12) = -1
>> EINVAL (Invalid argument)
>
> Reverting 97840cb67ff5ac8add836684f011fd838518d698 - netfilter:
> nfnetlink: fix insufficient validation in nfnetlink_bind
>
> makes everything work again on my systems.
>
> I'm testing with
>> # modprobe nfnetlink
>> # modprobe nf_conntrack_netlink
>> # modprobe nf_conntrack_ipv4
>> # conntrack -E
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

