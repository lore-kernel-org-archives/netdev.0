From: "David S. Miller" <davem@redhat.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Tue, 17 Sep 2002 14:49:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020917.144911.43656989.davem@redhat.com>
References: <3D87A264.8D5F3AD2@digeo.com>
	<20020917.143947.07361352.davem@redhat.com>
	<3D87A4A2.6050403@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@digeo.com, manfred@colorfullife.com, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@mandrakesoft.com
In-Reply-To: <3D87A4A2.6050403@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@mandrakesoft.com>
   Date: Tue, 17 Sep 2002 17:54:42 -0400

   David S. Miller wrote:
   > Any driver should be able to get the NAPI overhead to max out at
   > 2 PIOs per packet.
   
   Just to pick nits... my example went from 2 or 3 IOs [depending on the 
   presence/absence of a work loop] to 6 IOs.
   
I mean "2 extra PIOs" not "2 total PIOs".

I think it's doable for just about every driver, even tg3 with it's
weird semaphore scheme takes 2 extra PIOs worst case with NAPI.

The semaphore I have to ACK anyways at hw IRQ time anyways, and since
I keep a software copy of the IRQ masking register, mask and unmask
are each one PIO.
