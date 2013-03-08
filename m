From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: re L4 conntracking netns conversion
Date: Thu, 07 Mar 2013 17:32:19 -0800
Message-ID: <87sj46ptgc.fsf@xmission.com>
References: <CACVxJT9mPb+Fh7gc-PYwC288sjJct+-s5bSZ783j_6tiTNJKMg@mail.gmail.com>
	<51393870.1030709@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <51393870.1030709@cn.fujitsu.com> (Gao feng's message of "Fri, 08
	Mar 2013 09:01:36 +0800")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gao feng <gaofeng@cn.fujitsu.com> writes:

> On 2013/03/07 19:50, Alexey Dobriyan wrote:
>> Lots of netns changes!
>> 
>> I can't verify right now, but unless I'm not mistaken,
>> every L4 protocol conversion is buggy/oopsable/remotely ddosable
>> because per-netns stuff is initialized after protocol is hooked into
>> master dispatcher.
>> 
>
> Doesn't we do register_pernet_subsys before we register hooks and l4proto?
> Sorry I don't quite understand what you mean. :(

>> See c296bb4d5d417d466c9bcc8afef68a3db5449a64.

The registration in the referenced commit has register_pernet_subsys
happening after nf_ct_l4_proto_register.  The unregistration is also
happening in that order so something seems fishy.  If there is
an ordering dependency between the two unregistration should happen
in the opposite order of registration.

However, I don't know the code well enough to know if it is a problem or
not.

Eric


