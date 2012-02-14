From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Tue, 14 Feb 2012 11:08:21 -0800
Message-ID: <4F3AB125.2050104@intel.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab> <20120208203627.035c6b0e@nehalam.linuxnetplumber.net> <4F34042F.6090806@intel.com> <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net> <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu> <4F347D96.2020806@intel.com> <4F3499BC.8020609@intel.com> <1328887111.2075.43.camel@mojatatu> <4F39287F.6030204@intel.com> <1329225526.2806.34.camel@mojatatu> <4F3AAE80.4040609@intel.com> <20120214110504.418461bd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, jamal <hadi@cyberus.ca>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57054 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756950Ab2BNTH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 14:07:56 -0500
In-Reply-To: <20120214110504.418461bd@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/14/2012 11:05 AM, Stephen Hemminger wrote:
> On Tue, 14 Feb 2012 10:57:04 -0800
> John Fastabend <john.r.fastabend@intel.com> wrote:
> 
>> On 2/14/2012 5:18 AM, jamal wrote:
>>> On Mon, 2012-02-13 at 07:13 -0800, John Fastabend wrote:
>>>
>>>> The use case here is multiple VFs but the same solution should work with
>>>> multiple PFs as well. FDB controls should be independent of how the ports
>>>> are exposed VFs, PFs, VMDQ/queue pairs, macvlan, etc.
>>>
>>> Makes sense.
>>>
>>>> With events and ADD/DEL/GET FDB controls we can solve both cases. This also
>>>> solves Roopa's case with macvlan where she wants to add additional addresses
>>>> to macvlan ports.
>>>
>>> Not familiar with that issue - I'll prowl the list.
>>
>> Roopa was likely on the right track here,
>>
>> http://patchwork.ozlabs.org/patch/123064/
>>
>> But I think the proper syntax is to use the existing PF_BRIDGE:RTM_XXX
>> netlink messages. And if possible drive this without extending ndo_ops.
>>
>> An ideal user space interaction IMHO would look like,
>>
>> [root@jf-dev1-dcblab iproute2]# ./br/br fdb add 52:e5:62:7b:57:88 dev veth10
>> [root@jf-dev1-dcblab iproute2]# ./br/br fdb
>> port    mac addr                flags
>> veth2   36:a6:35:9b:96:c4       local
>> veth4   aa:54:b0:7b:42:ef       local
>> veth0   2a:e8:5c:95:6c:1b       local
>> veth6   6e:26:d5:43:a3:36       local
>> veth0   f2:c1:39:76:6a:fb
>> veth8   4e:35:16:af:87:13       local
>> veth10  52:e5:62:7b:57:88       static
>> veth10  aa:a9:35:21:15:c4       local
>> [root@jf-dev1-dcblab iproute2]# ./br/br fdb add dev eth3 to 52:e5:62:7b:57:88
>> RTNETLINK answers: Invalid argument
> 
> I am going to put bridge (nameclash with br) tool into iproute2 (soon).

I've been using it on my dev box for awhile now and it works well for
me.
