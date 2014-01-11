From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH net,stable] net: usbnet: fix SG initialisation
Date: Sun, 12 Jan 2014 00:22:09 +0800
Message-ID: <CACVXFVOxZVhLJMUZt9Bwsq=QwcFuDxKpJki5F2JH59iyZ=3uFw@mail.gmail.com>
References: <1389391817-27204-1-git-send-email-bjorn@mork.no>
	<CACVXFVPbi47ZLWm-AMeX1NLp3_BQWRSuWz7YjTXz-z3JmVoyRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Thomas Kear <thomas-hrxM1pTBpuF02iOg2JU2CQ@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVPbi47ZLWm-AMeX1NLp3_BQWRSuWz7YjTXz-z3JmVoyRA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 11, 2014 at 5:16 PM, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrot=
e:
> On Sat, Jan 11, 2014 at 6:10 AM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
>> Commit 60e453a940ac ("USBNET: fix handling padding packet")
>> added an extra SG entry in case padding is necessary, but
>> failed to update the initialisation of the list. This can
>> cause list traversal to fall off the end of the list,
>> resulting in an oops.
>>
>> Fixes: 60e453a940ac ("USBNET: fix handling padding packet")
>> Reported-by: Thomas Kear <thomas-hrxM1pTBpuF02iOg2JU2CQ@public.gmane.org>
>> Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Tested-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

On one of my arm box, I can reproduce the problem with below
command every time:

                   $iperf -c $SRV -l 2398 -n 1 #the 2nd tcp packet
length is 1016

and the oops is same with Thomas's. After applying Oliver's patch,
I still can see zlp padding packet is appended, but no oops any more.

Thanks Oliver for fixing the problem.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
