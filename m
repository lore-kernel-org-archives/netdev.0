From: Len Brown <lenb@kernel.org>
Subject: Re: [PATCH] ACPI: export acpi events via generic netlink
Date: Tue, 3 Jul 2007 15:45:16 -0400
Message-ID: <200707031545.16787.lenb@kernel.org>
References: <1182224403.5411.84.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-acpi@vger.kernel.org, netdev@vger.kernel.org, hadi@cyberus.ca
To: Zhang Rui <rui.zhang@intel.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1182224403.5411.84.camel@localhost.localdomain>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for including the demo program, Rui, it works for me (tm).

Applied -- with the incremental patch below, which I think
is correct because the only caller is bus.c, which is part of
the base kernel, not a module.  Modules will call
acpi_bus_generate_event(), not acpi_bus_generate_genetlink_event()
directly.

thanks,
-Len

commit b563d6f30d937510e02541930b1558d0f5759413
Author: Len Brown <len.brown@intel.com>
Date:   Tue Jul 3 15:32:23 2007 -0400

    ACPI: netlink: remove unnecessary EXPORT_SYMBOL
    
    Signed-off-by: Len Brown <len.brown@intel.com>

diff --git a/drivers/acpi/event.c b/drivers/acpi/event.c
index 98627b0..de4def9 100644
--- a/drivers/acpi/event.c
+++ b/drivers/acpi/event.c
@@ -221,7 +221,6 @@ int acpi_bus_generate_genetlink_event(struct acpi_device *device,
 				  "Failed to send a Genetlink message!\n"));
 	return 0;
 }
-EXPORT_SYMBOL(acpi_bus_generate_genetlink_event);
 
 static int acpi_event_genetlink_init(void)
 {
@@ -245,7 +244,6 @@ int acpi_bus_generate_genetlink_event(struct acpi_device *device, u8 type,
 {
 	return 0;
 }
-EXPORT_SYMBOL(acpi_bus_generate_genetlink_event);
 
 static int acpi_event_genetlink_init(void)
 {
