From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Allow TCP connections to cache SYN packet for userspace
 inspection
Date: Fri, 01 May 2015 13:41:34 -0700
Message-ID: <1430512894.3711.140.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430502237-5619-1-git-send-email-emunson@akamai.com>
	 <1430505777.3711.135.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34ftz_wDoPwcJg_cMQu4QtnBJF-=d+gF5ieTA=d=r31-Q@mail.gmail.com>
	 <20150501201417.GB6113@akamai.com>
	 <1430511800.3711.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150501202908.GC6113@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150501202908.GC6113-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-05-01 at 16:29 -0400, Eric B Munson wrote:

>  
> 
> As long as your implementation provides the IP and TCP headers, I would
> be happy with that.  I am also happy to rework my implementation to
> extract and cache information when the request structure is built.  If
> you all have an implementation that you want to post, I will add my ack
> if it meets our needs as well.

Yes, I believe it will be easier we provide our implementation instead
of reviewing yours ;)

For example you had :

+       case TCP_SAVED_SYN:
+               if (!((1 << sk->sk_state) & TCPF_LISTEN))
+                       err = -EINVAL;
+               tp->saved_syn = !!(val);
+               break;


But if you return an error, tp->saved_syn should be left unchanged.
