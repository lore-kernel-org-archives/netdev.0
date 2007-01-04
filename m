From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [openib-general] [PATCH  v4 01/13] Linux RDMA Core Changes
Date: Thu, 04 Jan 2007 13:34:27 -0800
Message-ID: <adawt424gt8.fsf@cisco.com>
References: <1167851839.4187.36.camel@stevo-desktop>
	<20070103193324.GD29003@mellanox.co.il>
	<1167855618.4187.65.camel@stevo-desktop>
	<1167859320.4187.81.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@mellanox.co.il>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965077AbXADVef@vger.kernel.org>
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1167859320.4187.81.camel@stevo-desktop> (Steve Wise's message of "Wed, 03 Jan 2007 15:22:00 -0600")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK, I'm back from vacation today.

Anyway I don't have a definitive statement on this right now.  I guess
I agree that I don't like having an extra parameter to a function that
should be pretty fast (although req notify isn't quite as hot as
something like posting a send request or polling a cq), given that it
adds measurable overhead.  (And I am surprised that the overhead is
measurable, since 3 arguments still fit in registers, but OK).

I also agree that adding an extra entry point just to pass in the user
data is ugly, and also racy.

Giving the kernel driver a pointer it can read seems OK I guess,
although it's a little ugly to have a backdoor channel like that.

I'm somewhat surprised the driver has to go into the kernel to rearm a
CQ -- what makes the operation need kernel privileges?  (Sorry for not
reading the code)
