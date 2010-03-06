From: Dan Carpenter <error27@gmail.com>
Subject: bug report: 9p: 9P2010.L handshake: Add mount option
Date: Sat, 6 Mar 2010 15:22:45 +0300
Message-ID: <20100306122245.GP4958@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sripathik@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:44819 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987Ab0CFMXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 07:23:02 -0500
Received: by fg-out-1718.google.com with SMTP id 16so1766826fgg.1
        for <netdev@vger.kernel.org>; Sat, 06 Mar 2010 04:23:00 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+static unsigned char get_protocol_version(const substring_t *name)
+{
+       unsigned char version = -EINVAL;

Assigning a negative value to an unsigned char is problematic.  (If it's 
an unsigned int or long that's different).

I have included a test program to illustrate.

regards,
dan carpenter

#include <stdio.h>

unsigned char n22(void) { return -22; }

int main()
{
	int ret = n22();

	if (ret == -22)
		printf("true\n");
	else 
		printf("false\n");
}

