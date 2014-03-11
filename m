From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vmxnet3: fix netpoll race condition
Date: Tue, 11 Mar 2014 16:15:59 -0400 (EDT)
Message-ID: <20140311.161559.441950272628803826.davem@davemloft.net>
References: <1394227527-31082-1-git-send-email-nhorman@tuxdriver.com>
	<1394448955-19915-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sbhatewara@vmware.com,
	pv-drivers@vmware.com, stable@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1394448955-19915-1-git-send-email-nhorman@tuxdriver.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 10 Mar 2014 06:55:55 -0400

> vmxnet3's netpoll driver is incorrectly coded.  It directly calls
> vmxnet3_do_poll, which is the driver internal napi poll routine.  As the netpoll
> controller method doesn't block real napi polls in any way, there is a potential
> for race conditions in which the netpoll controller method and the napi poll
> method run concurrently.  The result is data corruption causing panics such as this
> one recently observed:
 ...
> The fix is to do as other drivers do, and have the poll controller call the top
> half interrupt handler, which schedules a napi poll properly to recieve frames
> 
> Tested by myself, successfully.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
