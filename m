From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] ip netns: Make sure netns name is sane
Date: Wed, 12 Jul 2017 09:38:34 -0700
Message-ID: <20170712093834.3902c59d@xeon-e3>
References: <20170710111912.22537-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33142 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753183AbdGLQim (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 12:38:42 -0400
Received: by mail-pf0-f179.google.com with SMTP id e7so15607776pfk.0
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 09:38:42 -0700 (PDT)
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

Looks like natural place to use strdupa.

static bool is_basename(const char *name)
{
	return strcmp(basename(strdupa(name), name) == 0;
}
