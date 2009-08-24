From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: iproute2 / tbf with large burst seems broken again
Date: Tue, 25 Aug 2009 02:37:04 +0300
Message-ID: <200908250237.05017.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:52228 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753878AbZHXXjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 19:39:49 -0400
Received: from adminos.visp.net.lb (unknown [195.69.208.252])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id 0BF101A448F
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 02:39:43 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found issue, it seems tc_core_time2tick will overflow with increased 
resolution on large bucket values. But no idea how to fix it :-(

I add a warning, something like
 unsigned tc_core_time2tick(unsigned time)
 {
+       long long temp = time*tick_in_usec;
+       if (temp > INT_MAX)
+           printf("tc_core_time2tick() overflow!\n");
        return time*tick_in_usec;
 }

Maybe it is good to add in iproute2 mainstream, so user will be warned if 
buffer set too large? (and it will not set incorrect values, that lead to 
unpredictable results.
