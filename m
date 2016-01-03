From: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Patch net] nfc: check sock state in llcp_sock_getname()
Date: Sun, 3 Jan 2016 14:36:17 -0800
Message-ID: <CAM_iQpVMk5nutJ=F=mGR9vw4n0A8JJMODfpN_wt=_k5mwa+MBA@mail.gmail.com>
References: <1451694857-21873-1-git-send-email-xiyou.wangcong@gmail.com>
	<1451694857-21873-2-git-send-email-xiyou.wangcong@gmail.com>
	<CACT4Y+Y6YCYA_v=--spYpPDYj3Jo0cXcntFRe8XzYS3NJFUwqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACT4Y+Y6YCYA_v=--spYpPDYj3Jo0cXcntFRe8XzYS3NJFUwqQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 2, 2016 at 12:03 AM, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Sat, Jan 2, 2016 at 1:34 AM, Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> llcp_sock_getname() checks llcp_sock->dev to make sure
>> llcp_sock is already connected or bound, however, we could
>> be in the middle of llcp_sock_bind() where llcp_sock->dev
>> is bound and llcp_sock->service_name_len is set,
>> but llcp_sock->service_name is not, in this case we would
>> lead to copy some bytes from a NULL pointer.
>>
>> We should just check if sk->sk_state is still closed since
>> both connect() and bind() will update this state at the end.
>
> Hi Cong,
>
> This is still racy. If you want to play lock-free then you also need
> proper memory barriers. Stores to sk_state need to be
> smp_store_release, while the load needs to be smp_load_acquire.
> Otherwise getname still can see partially initialized socket.
>

Right... Or just lock sock perhaps. I will update my patch.

Thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
