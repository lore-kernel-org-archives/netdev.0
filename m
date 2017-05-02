From: David Miller <davem@davemloft.net>
Subject: bpf_test_finish()
Date: Mon, 01 May 2017 23:56:10 -0400 (EDT)
Message-ID: <20170501.235610.564976046138352257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41770 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdEBD4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 23:56:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It dereferences a user pointer:

static int bpf_test_finish(union bpf_attr __user *uattr, const void *data,
			   u32 size, u32 retval, u32 duration)
{
	void __user *data_out = u64_to_user_ptr(uattr->test.data_out);
                                                ^^^^^^^^^^^^^^^^^^^^
Which of course doesn't work so well :-)

I really wish that didn't silently work on x86/x86_64.

You're going to have to do a "get_user(&uattr->test.data_out)"
