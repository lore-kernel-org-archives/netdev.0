From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 3/3] ss: Fix width calculations when Netid or
 State columns are missing
Date: Tue, 31 Oct 2017 17:55:06 +0100
Message-ID: <20171031175506.6a7ff560@shemminger-XPS-13-9360>
References: <cover.1509307616.git.sbrivio@redhat.com>
        <e392e5bfa950ab752000ce40e7a43c3da03b1a53.1509307616.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Stefano Brivio <sbrivio@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:50456 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbdJaQzb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 12:55:31 -0400
Received: by mail-lf0-f46.google.com with SMTP id a132so19793050lfa.7
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 09:55:31 -0700 (PDT)
In-Reply-To: <e392e5bfa950ab752000ce40e7a43c3da03b1a53.1509307616.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 29 Oct 2017 21:22:34 +0100
Stefano Brivio <sbrivio@redhat.com> wrote:

> +	addrp_width -= netid_width + 1 * !!netid_width;
> +	addrp_width -= state_width + 1 * !!state_width;

Doing !! here is being too bit tricky for code that is not performance sensitive.
Just use an if statement or ? :

> @@ -4373,6 +4374,8 @@ int main(int argc, char *argv[])
>  			netid_width++;
>  		else if (state_width)
>  			state_width++;
> +		else
> +			odd_width_pad=" ";

Missing whitespace.
