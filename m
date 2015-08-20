From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.2 04/22] fjes: platform_driver's .probe and .remove
 routine
Date: Thu, 20 Aug 2015 15:51:28 -0700 (PDT)
Message-ID: <20150820.155128.302382371842900422.davem@davemloft.net>
References: <1440060306-13040-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1440060386-13189-4-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, platform-driver-x86@vger.kernel.org,
	dvhart@infradead.org, rkhan@redhat.com,
	alexander.h.duyck@redhat.com, linux-acpi@vger.kernel.org,
	joe@perches.com, sergei.shtylyov@cogentembedded.com,
	stephen@networkplumber.org, yasu.isimatu@gmail.com
To: izumi.taku@jp.fujitsu.com
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1440060386-13189-4-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Date: Thu, 20 Aug 2015 17:46:08 +0900

> +
> +err_register:
> +	fjes_hw_exit(&adapter->hw);
> +err_hw_init:
> +err_sw_init:
> +	free_netdev(netdev);
> +err_alloc_netdev:
> +	return err;

Having multiple code labels in the same exact spot is suboptimal.

Instead, name the labels such that they describe the first cleanup
action they will perform, instead of the context in which they are
jumped to from.

So "err_hw_exit:", "err_free_netdev", and "err_out:" would be
appropriate.
