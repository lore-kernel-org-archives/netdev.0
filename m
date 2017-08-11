From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Fri, 11 Aug 2017 09:48:49 -0700
Message-ID: <CAM_iQpWMWg5ytDq2Y9p9uet1zowGuCX+eksyiyxu9vQ18WoPxQ@mail.gmail.com>
References: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
 <CALAqxLXG8X2nkLEHM63oiY=M17vcpU2+-ec7x_aBWDCqrj4U-Q@mail.gmail.com>
 <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
 <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com>
 <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com>
 <CALAqxLXY-kE2N__eDq514cLycR0-QRpyOCMWpdttO6fgovE2rg@mail.gmail.com>
 <CAEA6p_C_rEYkJhcniyy6HUHgNxWFoxWzZ-WHsaSmNDwx4D+RXQ@mail.gmail.com>
 <CAEA6p_AOcNkAWPc7NFBnr8QWi3eHdJiQ2=8D_DB_XthwSDL2+Q@mail.gmail.com> <CALAqxLUoV6EQvofTEv9whW1_QMPBPU7eJBhRFUjaSs7CGeRFww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Wei Wang <weiwan@google.com>, lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALAqxLUoV6EQvofTEv9whW1_QMPBPU7eJBhRFUjaSs7CGeRFww@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Aug 10, 2017 at 11:12 AM, John Stultz <john.stultz@linaro.org> wrote:
> On Wed, Aug 9, 2017 at 10:41 PM, Wei Wang <weiwan@google.com> wrote:
>> Hi John,
>>
>> Is it possible to try the attached patch?
>
> Thanks so much for the quick turn around!
>
> So I dropped all the reverts you suggested, and applied this one
> against 4.13-rc4, but I'm still seeing the problematic behavior.

Does the following one-line fix make a difference?

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a640fbcba15d..c145a35763a0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -141,7 +141,7 @@ static void rt6_uncached_list_del(struct rt6_info *rt)
                struct uncached_list *ul = rt->rt6i_uncached_list;

                spin_lock_bh(&ul->lock);
-               list_del(&rt->rt6i_uncached);
+               list_del_init(&rt->rt6i_uncached);
                spin_unlock_bh(&ul->lock);
        }
 }
