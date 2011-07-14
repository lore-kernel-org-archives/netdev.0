From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: Re: [PATCH net-next] bonding: fix strlen errors in sysfs
Date: Thu, 14 Jul 2011 11:15:35 +0300
Message-ID: <201107141115.35452.vitas@nppfactor.kiev.ua>
References: <1310608665-12216-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Takuma Umeya <tumeya@redhat.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.cyfra.ua ([62.80.160.182]:49081 "EHLO mx3.cyfra.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751903Ab1GNIiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 04:38:16 -0400
In-Reply-To: <1310608665-12216-1-git-send-email-andy@greyhouse.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 14 July 2011 04:57:45 Andy Gospodarek wrote:
> -			if (strnicmp
> -			    (slave->dev->name, buf,
> -			     strlen(slave->dev->name)) == 0) {
> +			int max_len = max(strlen(slave->dev->name),
> +					  strlen(buf) - 1);
> +			if (strnicmp(slave->dev->name, buf, max_len) == 0) {

As for me there is no sense in preventing "address out of range" errors in  
strnicmp by calculating length with strlen first. If there is missing \0 at 
the end of the string you just shift failure point from stricmp to the strlen 
function call.
IMHO "maximum length" argument in strnicmp should be some appropriate constant 
instead. Alternatively we can use count:
 if (strnicmp(slave->dev->name, buf, count) == 0) {

> -			if (strnicmp
> -			    (slave->dev->name, buf,
> -			     strlen(slave->dev->name)) == 0) {
> +			int max_len = max(strlen(slave->dev->name),
> +					  strlen(buf) - 1);
> +			if (strnicmp(slave->dev->name, buf, max_len) == 0) {

Same here.

-- 
Vitalii
