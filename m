From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 2/3] netlink: Remove an unused pointer in netlink_skb_parms
Date: Thu, 21 Mar 2013 10:41:21 -0700
Message-ID: <CALCETrXEmxKmunP9HUORvT9rOjf4xu+7Fz9bZ=GXarcsYQNh7A@mail.gmail.com>
References: <cover.1363815201.git.luto@amacapital.net>
	<a8766c8b116b5e6fcaa932fe94f84a584554b98f.1363815201.git.luto@amacapital.net>
	<87d2ut1cpj.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2ut1cpj.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 20, 2013 at 11:36 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> net/ipv4/inet_diag.c:                      sk_user_ns(NETLINK_CB(in_skb).ssk),
> net/ipv4/inet_diag.c:                             sk_user_ns(NETLINK_CB(cb->skb).ssk),
> net/ipv4/inet_diag.c:                                          sk_user_ns(NETLINK_CB(cb->skb).ssk),
> net/ipv4/udp_diag.c:                    sk_user_ns(NETLINK_CB(cb->skb).ssk),
> net/ipv4/udp_diag.c:                       sk_user_ns(NETLINK_CB(in_skb).ssk),
> net/netfilter/nfnetlink_log.c:                                         sk_user_ns(NETLINK_CB(skb).ssk));
> net/netlink/af_netlink.c:               NETLINK_CB(skb).ssk = ssk;
> net/sched/cls_flow.c:               sk_user_ns(NETLINK_CB(in_skb).ssk) != &init_user_ns)
>
> I count 8 uses.

Whoops.  I clearly fail at grepping and building with the correct
configuration.  I'll drop this patch entirely -- it's independent of
the other two.

>
> Eric
>
>>
>> diff --git a/include/linux/netlink.h b/include/linux/netlink.h
>> index e0f746b..9ac1201 100644
>> --- a/include/linux/netlink.h
>> +++ b/include/linux/netlink.h
>> @@ -19,7 +19,6 @@ struct netlink_skb_parms {
>>       struct scm_creds        creds;          /* Skb credentials      */
>>       __u32                   portid;
>>       __u32                   dst_group;
>> -     struct sock             *ssk;
>>  };
>>
>>  #define NETLINK_CB(skb)              (*(struct netlink_skb_parms*)&((skb)->cb))



-- 
Andy Lutomirski
AMA Capital Management, LLC
