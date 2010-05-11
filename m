From: Joe Perches <joe@perches.com>
Subject: drivers/net/ RFC: Remove return; before void function
 end-of-functions close brace
Date: Mon, 10 May 2010 18:14:36 -0700
Message-ID: <1273540476.20514.61.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2132 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753880Ab0EKBOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 21:14:37 -0400
Received: from [192.168.1.151] (new-host-6.home [192.168.1.151])
	by mail.perches.com (Postfix) with ESMTP id DD6CD24368
	for <netdev@vger.kernel.org>; Mon, 10 May 2010 18:14:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many functions are declared void but use a return at end-of-function.

void function(void args...)
{
	[perform some calcs]
	...

	return;
}

Removing the unnecessary return; statements would save ~675 lines.
 
$ grep -rP --include=*.[ch] -l "return;\n}" drivers/net | \
  xargs perl -i -e 'local $/ ; while (<>) { s/\n[ \t\n]+return;\n}/\n}/g; print; }
$ git diff --shortstat drivers/net
 186 files changed, 0 insertions(+), 675 deletions(-)

Anyone think such patches acceptable/useful?

