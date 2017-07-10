From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] ip netns: Make sure netns name is sane
Date: Mon, 10 Jul 2017 08:17:02 -0700
Message-ID: <20170710081702.54cf6c8b@xeon-e3>
References: <20170710111912.22537-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35605 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754135AbdGJPRQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 11:17:16 -0400
Received: by mail-pf0-f174.google.com with SMTP id c73so51553772pfk.2
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 08:17:16 -0700 (PDT)
In-Reply-To: <20170710111912.22537-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jul 2017 13:19:12 +0200
Phil Sutter <phil@nwl.cc> wrote:

> +static bool is_basename(const char *name)
> +{
> +	char *name_dup = strdup(name);
> +	bool rc = true;
> +
> +	if (!name_dup)
> +		return false;
> +
> +	if (strcmp(basename(name_dup), name))
> +		rc = false;
> +
> +	free(name_dup);
> +	return rc;
> +}

Why not just:

static bool is_basename(const char *name)
{
	return strchr(name '/') == NULL;
}
