From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/3 net-next RFC] selftest: add abstractions for net selftests
Date: Tue, 09 Apr 2013 17:39:21 +0400
Message-ID: <51641A09.7040108@cogentembedded.com>
References: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com> <1365503461-26309-2-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, willemb@google.com,
	dborkman@redhat.com, edumazet@google.com,
	Daniel Baluta <dbaluta@ixiacom.com>
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:42065 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174Ab3DINkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 09:40:24 -0400
Received: by mail-lb0-f179.google.com with SMTP id t1so6881099lbd.10
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 06:40:22 -0700 (PDT)
In-Reply-To: <1365503461-26309-2-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09-04-2013 14:30, Alexandru Copot wrote:

> Signed-of by Alexandru Copot <alex.mihai.c@gmail.com>
> Cc: Daniel Baluta <dbaluta@ixiacom.com>
[...]

> diff --git a/tools/testing/selftests/net/selftests.c b/tools/testing/selftests/net/selftests.c
> new file mode 100644
> index 0000000..cd6e427
> --- /dev/null
> +++ b/tools/testing/selftests/net/selftests.c
> @@ -0,0 +1,30 @@
> +#include <stdio.h>
> +
> +#include "selftests.h"
> +
> +int run_all_tests(struct generic_test *test, void *param)
> +{
> +	int i;
> +	int rc, allrc;
> +	char *ptr;
> +
> +	rc = test->prepare ? test->prepare(param) : 0;
> +	if (rc)
> +		return rc;
> +
> +	allrc = 0;
> +	printf("Testing: %s ", test->name);
> +	ptr = test->testcases;
> +	for (i = 0; i < test->testcase_count; i++) {
> +		rc = test->run(ptr);
> +		allrc |= rc;
> +
> +		if (test->abort_on_fail && rc) {
> +			printf("Testcase %d failed, aborting\n", i);
> +		}

    Nit: {} not needed here, at least if you folow the Linux coding style (you 
seem to).

WBR, Sergei
