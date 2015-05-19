From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [Xen-devel] [RFC PATCH 09/13] xen-netfront: move grant_{ref,
 page} to struct grant
Date: Tue, 19 May 2015 10:19:23 +0000
Message-ID: <F1AA0F73-4A5F-4B2A-A948-79E854A52BAE@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-10-git-send-email-joao.martins@neclab.eu>
 <555A08F4.1030202@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:55437 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753623AbbESKTg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 06:19:36 -0400
In-Reply-To: <555A08F4.1030202@citrix.com>
Content-Language: en-US
Content-ID: <1FCB7E859BAC4244BC1D9BE2AC0E236B@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 18 May 2015, at 17:44, David Vrabel <david.vrabel@citrix.com> wrote:
> On 12/05/15 18:18, Joao Martins wrote:
>> Refactors a little bit how grants are stored by moving
>> grant_rx_ref/grant_tx_ref and grant_tx_page to its
>> own structure, namely struct grant.
> 
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>
> 
> Although...
> 
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -87,6 +87,11 @@ struct netfront_cb {
>> /* IRQ name is queue name with "-tx" or "-rx" appended */
>> #define IRQ_NAME_SIZE (QUEUE_NAME_SIZE + 3)
>> 
>> +struct grant {
>> +	grant_ref_t ref;
>> +	struct page *page;
>> +};
> 
> Is this sort of structure (and the following patch) useful for other
> frontends?

Perhaps not. It seems that blkfront is the only one that uses similar structure.
Though it creates a struct grant containing an additional struct list_node
field that is used for the free grants list within blkfront. In my case I
extend the struct grant later on the patch  "xen-netfront: implement RX 
persistent grants" to have the struct ubuf_info.
