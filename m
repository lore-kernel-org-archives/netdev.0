From: "ASIX_Allan [Home]" <allan@asix.com.tw>
Subject: RE: [PATCH v3 3/5] net: asix: Fix AX88772x resume failures
Date: Mon, 14 Nov 2016 16:50:44 +0800
Message-ID: <00e501d23e54$337d4b70$9a77e250$@asix.com.tw>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com> <c708db3f1e006df543284cf5215b965ce4fc44ec.1472155176.git-series.robert.foss@collabora.com> <77fa76d6-ef63-47db-a316-93b3a0c0705b@nvidia.com>
Reply-To: <allan@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'Jon Hunter'" <jonathanh@nvidia.com>, <robert.foss@collabora.com>,
        <freddy@asix.com.tw>, <Dean_Jenkins@mentor.com>,
        <Mark_Craske@mentor.com>, <davem@davemloft.net>,
        <ivecera@redhat.com>, <john.stultz@linaro.org>,
        <vpalatin@chromium.org>, <stephen@networkplumber.org>,
        <grundler@chromium.org>, <changchias@gmail.com>, <andrew@lunn.ch>,
        <tremyfr@gmail.com>, <colin.king@canonical.com>,
        <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <vpalatin@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <77fa76d6-ef63-47db-a316-93b3a0c0705b@nvidia.com>
Content-Language: zh-tw
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jon,

It seems the AX88772x dongle had been unexpectedly removed while running the
ax88772_suspend() routine. If yes, you might see these error messages
because the hardware had been absent.    

---
Best regards,
Allan Chou


-----Original Message-----
From: Jon Hunter [mailto:jonathanh@nvidia.com] 
Sent: Thursday, November 10, 2016 8:01 PM
To: robert.foss@collabora.com; freddy@asix.com.tw; Dean_Jenkins@mentor.com;
Mark_Craske@mentor.com; davem@davemloft.net; ivecera@redhat.com;
john.stultz@linaro.org; vpalatin@chromium.org; stephen@networkplumber.org;
grundler@chromium.org; changchias@gmail.com; allan@asix.com.tw;
andrew@lunn.ch; tremyfr@gmail.com; colin.king@canonical.com;
linux-usb@vger.kernel.org; netdev@vger.kernel.org;
linux-kernel@vger.kernel.org; vpalatin@google.com
Subject: Re: [PATCH v3 3/5] net: asix: Fix AX88772x resume failures

Hi Robert,

On 29/08/16 14:32, robert.foss@collabora.com wrote:
> From: Robert Foss <robert.foss@collabora.com>
> 
> From: Allan Chou <allan@asix.com.tw>
> 
> The change fixes AX88772x resume failure by
> - Restore incorrect AX88772A PHY registers when resetting
> - Need to stop MAC operation when suspending
> - Need to restart MII when restoring PHY
> 
> Signed-off-by: Allan Chou <allan@asix.com.tw>
> Signed-off-by: Robert Foss <robert.foss@collabora.com>
> Tested-by: Robert Foss <robert.foss@collabora.com>

After this commit, I have started seeing the following messages during
system suspend on various tegra boards using asix ethernet dongles ...

[  288.667010] PM: Syncing filesystems ... done.
[  288.672223] Freezing user space processes ... (elapsed 0.001 seconds)
done.
[  288.680505] Double checking all user space processes after OOM killer
disable... (elapsed 0.000 seconds) [  288.690193] Freezing remaining
freezable tasks ... (elapsed 0.001 seconds) done.
[  288.698987] Suspending console(s) (use no_console_suspend to debug) [
288.706605] asix 1-1:1.0 eth0: Failed to read reg index 0x0000: -19 [
288.706613] asix 1-1:1.0 eth0: Error reading Medium Status register:
ffffffed [  288.706621] asix 1-1:1.0 eth0: Failed to write reg index 0x0000:
-19 [  288.706629] asix 1-1:1.0 eth0: Failed to write Medium Mode mode to
0xfeed: ffffffed [  288.759167] PM: suspend of devices complete after 52.772
msecs

Interestingly, it only seems to happen if the ethernet is in a disconnected
state when entering suspend. I have not had chance to look at this any
further, but wanted to see if you had any thoughts.

Cheers
Jon

--
nvpublic
