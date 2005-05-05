From: Don Fry <brazilnut@us.ibm.com>
Subject: RFC ethtool usage
Date: Thu, 5 May 2005 16:41:28 -0700
Message-ID: <20050505234128.GA21736@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

One of the pieces of information that is useful for me when debugging
problems with the pcnet32 driver, is which chip version the problem
occurs with (79C973, 79C976, etc).

Since the chip has no firmware, how badly would I be flamed, if I
modified the driver to return the string (which is currently printed
on boot), as the 'firmware-version'?

--- orig.pcnet32.c      Mon May  2 15:12:02 2005
+++ pcnet32.c   Mon May  2 15:13:38 2005
@@ -559,6 +559,7 @@ static void pcnet32_get_drvinfo(struct n
 
     strcpy (info->driver, DRV_NAME);
     strcpy (info->version, DRV_VERSION);
+    strncpy(info->fw_version, lp->name, sizeof(info->fw_version) - 1);
     if (lp->pci_dev)
 	strcpy (info->bus_info, pci_name(lp->pci_dev));
     else

So the output looked like:
$ ethtool -i eth0
driver: pcnet32
version: 1.30j
firmware-version: PCnet/PRO 79C976
bus-info: 0000:00:01.0
$ 

-- 
Don Fry
brazilnut@us.ibm.com
