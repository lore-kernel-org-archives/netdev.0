From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH net-next v10 1/7] xen-netback: Move
 grant_copy_op array back into struct xenvif.
Date: Wed, 4 Jun 2014 15:52:52 +0100
Message-ID: <538F32C4.8070409@citrix.com>
References: <1401874247-3202-1-git-send-email-wei.liu2@citrix.com>
	<1401874247-3202-2-git-send-email-wei.liu2@citrix.com>
	<538F3152.80501@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: paul.durrant@citrix.com,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>,
	ian.campbell@citrix.com, zoltan.kiss@citrix.com, a.j.bennieston@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Wei Liu
	<wei.liu2@citrix.com>, <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <538F3152.80501@cogentembedded.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On 04/06/14 15:46, Sergei Shtylyov wrote:
> Hello.
> 
> On 06/04/2014 01:30 PM, Wei Liu wrote:
> 
>> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
>> This array was allocated separately in commit ac3d5ac2 ("xen-netback:
>> fix guest-receive-side array sizes") due to it being very large, and a
>> struct xenvif is allocated as the netdev_priv part of a struct
>> net_device, i.e. via kmalloc() but falling back to vmalloc() if the
>> initial alloc. fails.
> 
>> In preparation for the multi-queue patches, where this array becomes
>> part of struct xenvif_queue and is always allocated through vzalloc(),
>> move this back into the struct xenvif.
> 
>    Won't this cause an allocation failure and so break bisection at this
> patch?

No. As Andrew already said: "...falling back to vmalloc() if the
initial alloc. fails."

David
