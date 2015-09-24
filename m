From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] rtnl_fdb_dump: catch errors from ndo_fdb_dump
 and ndo_dflt_fdb_dump
Date: Wed, 23 Sep 2015 21:59:17 -0700
Message-ID: <CAE4R7bA9BqTF9UW95pfDujXo+jTfyDYcXfFCWthOJh_M0LQk4A@mail.gmail.com>
References: <1443025261-14951-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Dept-GELinuxNICDev@qlogic.com,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Wilson Kok <wkok@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:32792 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbbIXE7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 00:59:37 -0400
Received: by obbbh8 with SMTP id bh8so50010602obb.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 21:59:36 -0700 (PDT)
In-Reply-To: <1443025261-14951-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 9:21 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> From: Wilson Kok <wkok@cumulusnetworks.com>
>
> current ndo_fdb_dump and ndo_dflt_fdb_dump always return the current
> fdb index. They dont return errors. Which results in fdb dumps
> continuing on errors.
>
> In one such case where bridges and vxlan devices were involved,
> bridge driver returned -EMSGSIZE on a bridge, but since it continued
> on error, the next vxlan device fdb dump (which was smaller in size)
> succeeded, leaving fdb idx at an inconsistent value. This
> resulted in the bridge fdb entry getting skipped and vxlan
> fdb entry getting dumped twice.
>
> This patch changes ndo_fdb_dump() to return the status and pass the
> idx by reference for update. The dump aborts if non-zero status is
> returned.
>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Reviewed-by: Scott Feldman <sfeldma@gmail.com>
