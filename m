From: Pankaj Gupta <pagupta@redhat.com>
Subject: Re: [PATCH v2 net-next 3/3] tuntap: reduce the size of tun_struct
 by using flex array.
Date: Wed, 26 Nov 2014 02:40:14 -0500 (EST)
Message-ID: <538874253.4658840.1416987614805.JavaMail.zimbra@redhat.com>
References: <1416854044-10124-1-git-send-email-pagupta@redhat.com> <20141125.132717.122094133335261929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jasowang@redhat.com, dgibson@redhat.com, vfalico@gmail.com,
	edumazet@google.com, vyasevic@redhat.com, hkchu@google.com,
	xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125.132717.122094133335261929.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> From: Pankaj Gupta <pagupta@redhat.com>
> Date: Tue, 25 Nov 2014 00:04:04 +0530
> 
> > This patch switches to flex array to implement the flow caches, it brings
> > several advantages:
> > 
> > - Reduce the size of the tun_struct structure, which allows us to increase
> > the
> >   upper limit of queues in future.
> > - Avoid higher order memory allocation. It will be useful when switching to
> >   pure hashing in flow cache which may demand a larger size array in
> >   future.
> > 
> > After this patch, the size of tun_struct on x86_64 reduced from 8512 to
> > 328
> > 
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> > Reviewed-by: David Gibson <dgibson@redhat.com>
> 
> I see no reason to use flex arrays for this, you are preallocaing the
> memory so if anything flex array is adding an unnecessary level of
> redirection for every access in return for no real gains.
> 
> Just allocate the thing normally using kzalloc() or whatever.

I agree. Will do the changes and submit v3.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
