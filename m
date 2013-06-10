From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tuntap: fix a possible race between queue selection
 and changing queues
Date: Mon, 10 Jun 2013 14:33:14 -0700 (PDT)
Message-ID: <20130610.143314.1237579707705274760.davem@davemloft.net>
References: <1370421897-30933-1-git-send-email-jasowang@redhat.com>
	<20130605103332.GD31830@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130605103332.GD31830@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 5 Jun 2013 13:33:32 +0300

> On Wed, Jun 05, 2013 at 04:44:57PM +0800, Jason Wang wrote:
>> Complier may generate codes that re-read the tun->numqueues during
>> tun_select_queue(). This may be a race if vlan->numqueues were changed in the
>> same time and can lead unexpected result (e.g. very huge value).
>> 
>> We need prevent the compiler from generating such codes by adding an
>> ACCESS_ONCE() to make sure tun->numqueues were only read once.
>> 
>> Bug were introduced by commit c8d68e6be1c3b242f1c598595830890b65cea64a
>> (tuntap: multiqueue support).
>> 
>> Reported-by: Michael S. Tsirkin <mst@redhat.com>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> This is a theoretical problem, right?
> So no need for stable.

Applied, thanks.
