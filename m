From: Sathya Perla <sathya.perla@broadcom.com>
Subject: RE: [PATCH net-next 1/2] be2net: set temperature value for all
 adapter's functions
Date: Mon, 25 Jul 2016 16:18:13 +0530
Message-ID: <a231dccbdf9d054819aca387db6533c4@mail.gmail.com>
References: <1469237395-11501-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>,
	Ajit Kumar Khaparde <ajit.khaparde@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33892 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbcGYKsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 06:48:15 -0400
Received: by mail-qk0-f174.google.com with SMTP id o67so152930678qke.1
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 03:48:14 -0700 (PDT)
In-Reply-To: <1469237395-11501-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Guilherme G. Piccoli [mailto:gpiccoli@linux.vnet.ibm.com]
>
> Temperature values on be2net driver are made available to userspace via
hwmon abstraction, so tools like lm-
> sensors can present them to the user.
> The driver provides hwmon structures for each adapter's function.
> Nevertheless, the temperature information come from fw queries performed
by
> be_worker() with some frequency, and this procedure is called with a
single function as argument; this means
> that the temperature value is updated only in the specific function that
was passed to be_worker().
>
> This can lead to incongruency in reported temperature by a function, or
in a worse scenario, some functions
> might be unable to provide temperature info to userspace, if they
weren't fed with this information from fw in
> be_worker() run.

Hi, I'm wondering if you are OK with the temperature value being 128s old
(2/2 patch), then why is it a problem
if two different functions report a temperature value that is queried a
few seconds apart?
Also, you'll not have a scenario where the FW cmd succeeds for one
function and fails for other functions.
It's a common FW for the entire adapter.

>
> This patch changes the way temperature is set in be2net driver. At
anytime the fw query is performed, it will set
> the temperature value for all functions of the adapter, instead of only
setting the temperature of the function
> passed to be_worker().
If the possible inconsistency across functions is indeed a problem, then a
simpler solution would be to
issue the FW cmd synchronously when the sysfs attr is read, i.e., in
be_hwmon_show_temp() routine itself.

thanks!
-Sathya
