From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch] poll.2: timeout_ts is a pointer, so use -> not . for
 member access
Date: Wed, 23 Dec 2015 23:29:13 +0100
Message-ID: <CAKgNAkgQS2ifFhP+Z2mQM1ryTNCzUzdV6Jc=oPg-kCZs-GA4OA@mail.gmail.com>
References: <CAO_2OxVnn4cmvX5fZmXYHgW6v3aoH=OAGrk62QgrTA=qYrrcew@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "richardvoigt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <richardvoigt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAO_2OxVnn4cmvX5fZmXYHgW6v3aoH=OAGrk62QgrTA=qYrrcew-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Richard,

On 23 December 2015 at 20:30, richardvoigt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
<richardvoigt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> From the context, it is apparent that in the code explaining ppoll in
> terms of poll, timeout_ts must be a pointer.
>
> Usage #1:   ready = ppoll(&fds, nfds, timeout_ts, &sigmask);
>
> Usage #2:    (timeout_ts == NULL)
>
> Thus member access in (timeout_ts.tv_sec * 1000 + timeout_ts.tv_nsec /
> 1000000) is an error.

Thanks. Patch applied.

Cheers,

Michael


> man2/poll.2 | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/man2/poll.2 b/man2/poll.2
> index bcbecad..34b55a6 100644
> --- a/man2/poll.2
> +++ b/man2/poll.2
> @@ -266,7 +266,7 @@ executing the following calls:
>      int timeout;
>
>      timeout = (timeout_ts == NULL) ? \-1 :
> -              (timeout_ts.tv_sec * 1000 + timeout_ts.tv_nsec / 1000000);
> +              (timeout_ts\->tv_sec * 1000 + timeout_ts\->tv_nsec / 1000000);
>      pthread_sigmask(SIG_SETMASK, &sigmask, &origmask);
>      ready = poll(&fds, nfds, timeout);
>      pthread_sigmask(SIG_SETMASK, &origmask, NULL);



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
