From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Subject: Re: [PATCH 2.6.0-test4][NET] 3c509.c: remove device.name field
Date: 24 Aug 2003 17:55:40 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061727940.1288.4.camel@lima.royalchallenge.com>
References: <1061644409.1141.18.camel@lima.royalchallenge.com>
	<20030824034735.534b8c68.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030824034735.534b8c68.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

On Sun, 2003-08-24 at 16:17, David S. Miller wrote:
> On 23 Aug 2003 18:43:29 +0530
> Vinay K Nallamothu <vinay-rc@naturesoft.net> wrote:
> 
> > This patch removes the device name field which is no longer present.
> 
> This doesn't look like the right fix.  You can't just
> delete these lines, you should rather replace them with
> accesses to whatever the MCA device struct name field is.
> 
> 
Pls find the updated patch (hopefully right this time) below:

Thanks
vinay

--- linux-2.6.0-test4/drivers/net/3c509.c	2003-08-23 13:14:30.000000000 +0530
+++ linux-2.6.0-test4-nvk/drivers/net/3c509.c	2003-08-24 17:51:19.000000000 +0530
@@ -629,8 +629,8 @@
 			   el3_mca_adapter_names[mdev->index], slot + 1);
 
 		/* claim the slot */
-		strncpy(device->name, el3_mca_adapter_names[mdev->index],
-				sizeof(device->name));
+		strncpy(mdev->name, el3_mca_adapter_names[mdev->index],
+				sizeof(mdev->name));
 		mca_device_set_claim(mdev, 1);
 
 		if_port = pos4 & 0x03;
