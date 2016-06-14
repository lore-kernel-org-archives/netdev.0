From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: padata - is serial actually serial?
Date: Tue, 14 Jun 2016 23:00:54 +0200
Message-ID: <CAHmME9qnufO90qF7v9bVb7L+6KQA=kaZ=BML2sRwzbQHtFLJGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-crypto@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:33130 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752779AbcFNVBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 17:01:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen & Folks,

I submit a job to padata_do_parallel(). When the parallel() function
triggers, I do some things, and then call padata_do_serial(). Finally
the serial() function triggers, where I complete the job (check a
nonce, etc).

The padata API is very appealing because not only does it allow for
parallel computation, but it claims that the serial() functions will
execute in the order that jobs were originally submitted to
padata_do_parallel().

Unfortunately, in practice, I'm pretty sure I'm seeing deviations from
this. When I submit tons and tons of tasks at rapid speed to
padata_do_parallel(), it seems like the serial() function isn't being
called in the exactly the same order that tasks were submitted to
padata_do_parallel().

Is this known (expected) behavior? Or have I stumbled upon a potential
bug that's worthwhile for me to investigate more?

Thanks,
Jason
