From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 19/19] netfilter: gre: fix resource leak when unregister
 gre proto
Date: Mon, 07 Jan 2013 10:59:43 +0800
Message-ID: <50EA3A1F.8020108@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com> <1356662206-2260-20-git-send-email-gaofeng@cn.fujitsu.com> <20130105035048.GA20027@1984> <50EA2489.3070309@cn.fujitsu.com> <20130107021517.GA12215@1984> <20130107023808.GA14431@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	canqunzhang@gmail.com, kaber@trash.net, ebiederm@xmission.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130107023808.GA14431@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/07/13 10:38, Pablo Neira Ayuso wrote:
> On Mon, Jan 07, 2013 at 03:15:17AM +0100, Pablo Neira Ayuso wrote:
>> Hi Gao,
>>
>> On Mon, Jan 07, 2013 at 09:27:37AM +0800, Gao feng wrote:
>>> Hi Pablo,
>>>
>>> On 01/05/13 11:50, Pablo Neira Ayuso wrote:
>>>> Hi Gao,
>>>>
>>>> On Fri, Dec 28, 2012 at 10:36:46AM +0800, Gao feng wrote:
>>>>> Currectly we unregister proto before all conntrack entries of
>>>>> this proto being destroyed. so in function destroy_conntrack
>>>>> we can't find proper l4proto to call l4proto->destroy.
>>>>> this will cause resource leak.
>>>>
>>>> Good catch.
>>>>
>>>> But better to remove the entries before unregistering the protocol
>>>> tracker, so l4proto->destroy is always called.
>>>>
>>>
>>> I think the reason we unregister proto before remove all entries
>>> is to avoid new entry for this protocol being created.
>>>
>>> If we remove all contrack entries before unregistration, there maybe
>>> some new entries being created between nf_ct_iterate_cleanup and
>>> nf_conntrack_l4proto_unregister_net.this will cause some terrible things.
>>
>> Leaks are less likely to happen, but may well still happen while
>> racing with protocol removal, agreed.
>>
>>> SO I think we should make proto unavailable first,remove all entries next,
>>> and remove proto from nf_ct_protos arrays finally.
>>
>> Your proposal adds a branch in the packet path to fix an issue that is
>> specific of the GRE protocol tracker. In the current code, this fixes
>> the memory leak while removing the nf_conntrack_proto_gre module,
>> which is a rare operation.
>>
>> We have to come with a less intrusive solution.
> 
> Wait. The existing code is calling nf_ct_gre_keymap_flush in
> proto_gre_net_exit path, so those keymap objects are not leaked.

Agree, it looks like nf_ct_gre_keymap_flush is added to solve this
problem.

Please ignore this patch.

Thanks!
