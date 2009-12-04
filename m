From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: linux-next: manual merge of the sysctl tree with the net tree
Date: Fri, 04 Dec 2009 13:42:49 -0800
Message-ID: <m1vdgmbeli.fsf@fess.ebiederm.org>
References: <20091204194301.ca77fe40.sfr@canb.auug.org.au>
	<4B18FDA3.5060601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4B18FDA3.5060601@gmail.com> (William Allen Simpson's message of "Fri\, 04 Dec 2009 07\:16\:35 -0500")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson <william.allen.simpson@gmail.com> writes:

> Stephen Rothwell wrote:
>> Hi Eric,
>>
>> Today's linux-next merge of the sysctl tree got a conflict in
>> net/ipv4/sysctl_net_ipv4.c between commit
>> 519855c508b9a17878c0977a3cdefc09b59b30df ("TCPCT part 1c:
>> sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS") from the
>> net tree and commit f8572d8f2a2ba75408b97dc24ef47c83671795d7 ("sysctl
>> net: Remove unused binary sysctl code") from the sysctl tree.
>>
>> I fixed it up (see below) and can carry the fix as necessary.
>
> Hi, I'm not Eric, but it's my TCPCT patch -- is there something more
> that I need to do?
>
> Adding a sysctl was my very first query to Linux lists.  I thought
> everything was covered in that and subsequent threads.

My apologies for not giving you a heads up earlier.

You initially ran into the problem in sysctl_check where you added a
new binary sysctl and you had errors.  That works to keep people from
adding new binary sysctl but as you experienced it is not the most
obvious way of communicating.

In my sysctl tree I have written a compatibility layer for all of the
existing binary sysctl handlers, and have removed the .ctl_name and
.strategy fields, that used to be used for implementing binary
sysctls.

In the best case scenario you could have seen that coming and not
included the .ctl_name line in your patch.  Then there would have been
a trivial conflict that would have required no changes to fixup.
However since I removed .ctl_name from before and after your new entry
a minor merge conflict was inevitable.

The price it seems for multiple independent development trees are the
occasionally conflicts in trees hosting kernel wide cleanups and fixes.

Eric
