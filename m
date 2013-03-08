From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: re L4 conntracking netns conversion
Date: Fri, 08 Mar 2013 09:56:29 +0800
Message-ID: <5139454D.70706@cn.fujitsu.com>
References: <CACVxJT9mPb+Fh7gc-PYwC288sjJct+-s5bSZ783j_6tiTNJKMg@mail.gmail.com> <51393870.1030709@cn.fujitsu.com> <87sj46ptgc.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:20790 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760146Ab3CHBzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 20:55:47 -0500
In-Reply-To: <87sj46ptgc.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/03/08 09:32, Eric W. Biederman wrote:
> Gao feng <gaofeng@cn.fujitsu.com> writes:
> 
>> On 2013/03/07 19:50, Alexey Dobriyan wrote:
>>> Lots of netns changes!
>>>
>>> I can't verify right now, but unless I'm not mistaken,
>>> every L4 protocol conversion is buggy/oopsable/remotely ddosable
>>> because per-netns stuff is initialized after protocol is hooked into
>>> master dispatcher.
>>>
>>
>> Doesn't we do register_pernet_subsys before we register hooks and l4proto?
>> Sorry I don't quite understand what you mean. :(
> 
>>> See c296bb4d5d417d466c9bcc8afef68a3db5449a64.
> 
> The registration in the referenced commit has register_pernet_subsys
> happening after nf_ct_l4_proto_register.  The unregistration is also
> happening in that order so something seems fishy.  If there is
> an ordering dependency between the two unregistration should happen
> in the opposite order of registration.
> 

Yes, we have the incorrect order when registering l4proto_sctp/gre/dccp/udplite.

> However, I don't know the code well enough to know if it is a problem or
> not.
> 

Had better to fix this problem, Since the l4proto may access the memory before
register_pernet_subsys allocates it.

Thanks
