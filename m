From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH v2] iproute2 tests: Fix problem with test running
Date: Sat, 6 Sep 2014 13:31:09 +0300
Message-ID: <CAMw6YJ+5qR2o6NNwD7RNPLoqLwMDT57kWXRQWehYJwbiQA4nYg@mail.gmail.com>
References: <1409937036-30712-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:38741 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbaIFKbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 06:31:10 -0400
Received: by mail-qa0-f50.google.com with SMTP id cm18so11903903qab.37
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 03:31:09 -0700 (PDT)
In-Reply-To: <1409937036-30712-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will re-send patch v2 with using "sudo -E".

On Fri, Sep 5, 2014 at 8:10 PM, Vadim Kochan <vadim4j@gmail.com> wrote:
> Tests were not allowed to be ran, the following
> issues were fixed:
>     - creating the results folder before test running
>     - sudo $PREFIX moved before variables definition which
>         allow to pass them through the sudo to test script.
>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  testsuite/Makefile | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
>
> diff --git a/testsuite/Makefile b/testsuite/Makefile
> index 2a4e0ba..648c793 100644
> --- a/testsuite/Makefile
> +++ b/testsuite/Makefile
> @@ -1,6 +1,7 @@
>  ## -- Config --
>  DEV := lo
>  PREFIX := sudo
> +RESULTS_DIR := results
>  ## -- End Config --
>
>  TESTS := $(patsubst tests/%,%,$(wildcard tests/*.t))
> @@ -23,23 +24,24 @@ listtests:
>  alltests: $(TESTS)
>
>  clean:
> -       @rm -rf results/*
> +       @rm -rf $(RESULTS_DIR)
>
>  distclean: clean
>         echo "Entering iproute2" && cd iproute2 && $(MAKE) distclean && cd ..;
>
>  $(TESTS):
> +       @mkdir -p $(RESULTS_DIR)
>         @for i in $(IPVERS); do \
>                 o=`echo $$i | sed -e 's/iproute2\///'`; \
>                 echo -n "Running $@ [$$o/`uname -r`]: "; \
> -               TC="$$i/tc/tc" IP="$$i/ip/ip" DEV="$(DEV)" IPVER="$@" SNAME="$$i" \
> -               ERRF="results/$@.$$o.err" $(KENV) $(PREFIX) tests/$@ > results/$@.$$o.out; \
> +               $(PREFIX) TC="$$i/tc/tc" IP="$$i/ip/ip" DEV="$(DEV)" IPVER="$@" SNAME="$$i" \
> +               ERRF="$(RESULTS_DIR)/$@.$$o.err" $(KENV) tests/$@ > $(RESULTS_DIR)/$@.$$o.out; \
>                 if [ "$$?" = "127" ]; then \
>                         echo "SKIPPED"; \
> -               elif [ -e "results/$@.$$o.err" ]; then \
> +               elif [ -e "$(RESULTS_DIR)/$@.$$o.err" ]; then \
>                         echo "FAILED"; \
>                 else \
>                         echo "PASS"; \
>                 fi; \
> -               dmesg > results/$@.$$o.dmesg; \
> +               dmesg > $(RESULTS_DIR)/$@.$$o.dmesg; \
>         done
> --
> 2.1.0
>
