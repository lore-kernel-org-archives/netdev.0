From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 16/16] tipc: make netlink
	support net namespace
Date: Sat, 10 Jan 2015 14:04:54 +0800
Message-ID: <54B0C106.6000103@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
	<1420788433-17960-17-git-send-email-ying.xue@windriver.com>
	<54AFDABB.3080103@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Tero.Aho@coriant.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <54AFDABB.3080103@cogentembedded.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 01/09/2015 09:42 PM, Sergei Shtylyov wrote:
> Hello.
> 
> On 1/9/2015 10:27 AM, Ying Xue wrote:
> 
>> Currently tipc module only allows users sitting on "init_net" namespace
>> to configure it through netlink interface. But now almost each tipc
>> component is able to be aware of net namespace, so it's time to open
>> the permission for users residing in other namespaces, allowing them
>> to configure their own tipc stack instance through netlink interface.
> 
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> Tested-by: Tero Aho <Tero.Aho@coriant.com>
>> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
>> ---
>>   net/tipc/netlink.c |    7 +++++--
>>   1 file changed, 5 insertions(+), 2 deletions(-)
> 
>> diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
>> index 282b596..fe0f513 100644
>> --- a/net/tipc/netlink.c
>> +++ b/net/tipc/netlink.c
>> @@ -54,7 +54,8 @@ static int handle_cmd(struct sk_buff *skb, struct
>> genl_info *info)
>>       int hdr_space = nlmsg_total_size(GENL_HDRLEN + TIPC_GENL_HDRLEN);
>>       u16 cmd;
>>
>> -    if ((req_userhdr->cmd & 0xC000) && (!netlink_capable(skb,
>> CAP_NET_ADMIN)))
>> +    if ((req_userhdr->cmd & 0xC000) &&
>> +        (!netlink_net_capable(skb, CAP_NET_ADMIN)))
> 
>    Why? Also, it seems like unrelated change...
> 

Without above change, the line length is over 80 characters. Of course,
this change is not much related to what the patch is really doing.

Regards,
Ying

> [...]
> 
> WBR, Sergei
> 
> 
> 


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
