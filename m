From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qrtr: fix build problems
Date: Mon, 16 May 2016 13:45:12 -0400 (EDT)
Message-ID: <20160516.134512.245412616243380218.davem@davemloft.net>
References: <1463145025-4011396-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn.andersson@sonymobile.com, courtney.cavin@sonymobile.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463145025-4011396-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 13 May 2016 15:09:58 +0200

> Having multiple loadable modules with the same name cannot work
> with modprobe, and having both net/qrtr/smd.ko and drivers/soc/qcom/smd.ko
> results in a (somewhat cryptic) build error:
> 
> ERROR: "qcom_smd_driver_unregister" [net/qrtr/smd.ko] undefined!
> ERROR: "qcom_smd_driver_register" [net/qrtr/smd.ko] undefined!
> ERROR: "qcom_smd_set_drvdata" [net/qrtr/smd.ko] undefined!
> ERROR: "qcom_smd_send" [net/qrtr/smd.ko] undefined!
> ERROR: "qcom_smd_get_drvdata" [net/qrtr/smd.ko] undefined!
> ERROR: "qcom_smd_driver_unregister" [drivers/soc/qcom/wcnss_ctrl.ko] undefined!
> ERROR: "qcom_smd_driver_register" [drivers/soc/qcom/wcnss_ctrl.ko] undefined!
> ERROR: "qcom_smd_set_drvdata" [drivers/soc/qcom/wcnss_ctrl.ko] undefined!
> ERROR: "qcom_smd_send" [drivers/soc/qcom/wcnss_ctrl.ko] undefined!
> ERROR: "qcom_smd_get_drvdata" [drivers/soc/qcom/wcnss_ctrl.ko] undefined!
> 
> Also, the qrtr driver uses the SMD interface and has a Kconfig dependency,
> but also allows for compile-testing when SMD is disabled. However, if
> with QCOM_SMD=m and COMPILE_TEST=y we can end up with QRTR_SMD=y and
> that fails with a related link error.
> 
> The changes the dependency so we can still compile-test the driver but
> not have it built-in if SMD is a module, to avoid running in the broken
> configuration, and changes the Makefile to provide the driver under
> a different module name.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: bdabad3e363d ("net: Add Qualcomm IPC router")

Applied.
