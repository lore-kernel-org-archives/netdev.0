From: Len Brown <lenb@kernel.org>
Subject: Re: Regression on VIA C3 motherboard, commit: 66f2173e2
Date: Fri, 06 Feb 2009 13:57:47 -0500 (EST)
Message-ID: <alpine.LFD.2.00.0902061350470.26256@localhost.localdomain>
References: <498A93E5.2080509@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, linux-acpi@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-reply-to: <498A93E5.2080509@candelatech.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for the bisect, Ben.

Please test the patch below.

I assume even without the patch, booting with "acpi=off" on your
BIOS-ACPI-disabled box works?  (if no, this patch will not solve
all your problems, for you have additional trouble elsewhere)

I am curious why you're running a CONFIG_ACPI=y kernel
for a box with ACPI disabled. (though yes, it is supposed to work)

I'm even more curious what bad things happen when
you enable ACPI in the BIOS -- can you let me know
and we can try to fix them so the machine can run as shipped?

thanks,
-Len Brown
Intel Open Source Technology Center

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 775c97a..a885295 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -293,7 +293,12 @@ static void __init check_multiple_madt(void)
 
 int __init acpi_table_init(void)
 {
-	acpi_initialize_tables(initial_tables, ACPI_MAX_TABLES, 0);
+	acpi_status status;
+
+	status = acpi_initialize_tables(initial_tables, ACPI_MAX_TABLES, 0);
+	if (ACPI_FAILURE(status))
+		return 1;
+
 	check_multiple_madt();
 	return 0;
 }
