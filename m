From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Sun, 10 May 2015 23:44:15 +0200
Message-ID: <554FD12F.2020607@iogearbox.net>
References: <1431277170-4618-3-git-send-email-pablo@netfilter.org> <554F9946.9040707@plumgrid.com> <20150510175934.GA3799@salvia> <554F9DE8.3000507@plumgrid.com> <20150510182414.GA4198@salvia> <554FA7A5.5020400@plumgrid.com> <20150510190039.GA4938@salvia> <554FAC3A.40701@plumgrid.com> <20150510192044.GA7173@salvia> <554FB366.7080509@plumgrid.com> <20150510195018.GA7877@salvia> <554FCE24.8020904@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48414 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbbEJVoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 17:44:23 -0400
In-Reply-To: <554FCE24.8020904@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2015 11:31 PM, Daniel Borkmann wrote:
> On 05/10/2015 09:50 PM, Pablo Neira Ayuso wrote:
> ...
>> The numbers show that the existing approach and your approach results
>> in less performance for everyone that don't need to filter from
>> ingress. We have to move ingress to where it belongs.
>
> Your cleanup in patch 1 is okay, thanks for spotting it Pablo.
>
> I agree with you on the qdisc_enqueue_root(), it's not needed, which I
> removed in my set as well. Please note that my set doesn't introduce a
> regression, it improves ingress performance however.
>
> If there's no ingress user than that code path is simply *nop*'ed out.
> If there's one ingress present on one device but not on others, it also
> doesn't make anything slower to the current state. And you can also always
> compile out CONFIG_NET_CLS_ACT (which we actually could make more fine
> grained), if you really care.

But I am still wondering, does your machine have static_key support?
If nothing is enabled, the code runs through a straight-line code path,
it's a nop that is there.

> A next possible step would be to get rid of the ingress netdev queue so
> we can also reduce memory overhead. The only thing that is needed is
> the classifier list, which is then being invoked, we all have stated
> that many times previously.
>
> My other concern is, if we export qdisc_ingress_hook function pointer,
> out of tree modules can simply do rcu_assign_pointer(qdisc_ingress_hook,
> my_own_handler) to transparently implement their own hook, hm.
