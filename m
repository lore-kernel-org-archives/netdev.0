From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V8 2/4 net-next] skbuff: skb supports zero-copy buffers
Date: Thu, 07 Jul 2011 11:32:25 -0700
Message-ID: <1310063545.10209.30.camel@localhost.localdomain>
References: <1309990932.10209.19.camel@localhost.localdomain>
	 <20110707.040149.441417258943576903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110707.040149.441417258943576903.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-07-07 at 04:01 -0700, David Miller wrote:
> From: Shirley Ma <mashirle@us.ibm.com>
> Date: Wed, 06 Jul 2011 15:22:12 -0700
> 
> > +                     while (head) {
> > +                             put_page(head);
> > +                             head = (struct page *)head->private;
> > +                     }
> 
> Looks like you might be referencing the page after it's
> release here.  I think you need something like:
> 
>                         while (head) {
>                                 struct page *next = (struct page
> *)head->private;
>                                 put_page(head);
>                                 head = next;
>                         }
> --

You are right, will fix it.

Thanks
Shirley
 

