From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] ibmveth: set correct gso_size and gso_type
Date: Fri, 09 Dec 2016 19:28:41 -0800
Message-ID: <1481340521.4930.203.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481236803-4807-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
         <1481333480-10827-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
        pradeeps@linux.vnet.ibm.com, marcelo.leitner@gmail.com,
        jmaxwell37@gmail.com, zdai@us.ibm.com
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36122 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbcLJD2n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 22:28:43 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so4113703pgx.3
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 19:28:43 -0800 (PST)
In-Reply-To: <1481333480-10827-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-09 at 19:31 -0600, Thomas Falcon wrote:
> This patch is based on an earlier one submitted
> by Jon Maxwell with the following commit message:
> 

> +					DIV_ROUND_UP(skb->len - hdr_len, mss);
> +	} else if (offset) {
> +		skb_shinfo(skb)->gso_size = ntohs(tcph->check);
> +		skb_shinfo(skb)->gso_segs =
> +				DIV_ROUND_UP(skb->len - hdr_len,
> +					     skb_shinfo(skb)->gso_size);
> +		tcph->check = 0;
> +	}

Are you sure that tcph->check could never be 0 on some cases ?

That would crash on a divide by 0
