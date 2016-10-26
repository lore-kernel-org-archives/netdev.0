From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable
 sock modifications
Date: Wed, 26 Oct 2016 10:08:33 -0600
Message-ID: <993982d6-7192-cde5-6fcb-a2fa04f93389@cumulusnetworks.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
 <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
 <20161026084155.GA16001@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36301 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932188AbcJZQIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 12:08:36 -0400
Received: by mail-pf0-f180.google.com with SMTP id e6so141805423pfk.3
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 09:08:35 -0700 (PDT)
In-Reply-To: <20161026084155.GA16001@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/16 2:41 AM, Thomas Graf wrote:
> On 10/25/16 at 03:30pm, David Ahern wrote:
>> @@ -171,6 +177,9 @@ int __cgroup_bpf_run_filter(struct sock *sk,
>>  		case BPF_CGROUP_INET_EGRESS:
>>  			ret = __cgroup_bpf_run_filter_skb(skb, prog);
>>  			break;
>> +		case BPF_CGROUP_INET_SOCK_CREATE:
>> +			ret = __cgroup_bpf_run_filter_sk_create(sk, prog);
>> +			break;
>>  		/* make gcc happy else complains about missing enum value */
>>  		default:
>>  			return 0;
> 
> Thinking further ahead of your simple example. Instead of adding yet
> another prog type for the same hook, we can make this compatible with
> BPF_CGROUP_INET_EGRESS instead which would then provide a ctx which
> contains both, the sk and skb.
> 
> The ctx concept is very flexible. We can keep the existing dummy skb
> representation and add sk_ fields which are only valid for BPF at
> socket layer, e.g skb->sk_bound_dev_if would translate to
> sk->bound_dev_if.
> 

It's an odd user semantic to me to put sock elements into the shadow sk_buff and to reuse BPF_CGROUP_INET_EGRESS. 

I can drop the _CREATE and just make it BPF_CGROUP_INET_SOCK so it works for any sock modification someone wants to add -- e.g., the port binding use case.
