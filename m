From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Fwd: [Bug 4774] e1000 driver works on UP, but not SMP x86_64
Date: Sat, 25 Jun 2005 01:57:13 +0400
Message-ID: <200506250157.14499.adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263346AbVFXVxu@vger.kernel.org>
To: David Lang <david.lang@digitalinsight.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David, please try this debugging patch.

You can also register at http://bugme.osdl.org/createaccount.cgi and add
yourself to CC list.

----------  Forwarded Message  ----------

Subject: [Bug 4774] e1000 driver works on UP, but not SMP x86_64
Date: Saturday 25 June 2005 01:27
From: bugme-daemon@kernel-bugs.osdl.org
To: adobriyan@gmail.com

http://bugzilla.kernel.org/show_bug.cgi?id=4774


------- Additional Comments From nacc@us.ibm.com  2005-06-24 14:27 -------
Created an attachment (id=5211)
 --> (http://bugzilla.kernel.org/attachment.cgi?id=5211&action=view)
Debugging patch

That e1000 error message indicates an EINVAL error code, which is from this
code:

	if ((irqflags & SA_SHIRQ) && !dev_id)
		return -EINVAL;
	if (irq >= NR_IRQS)
		return -EINVAL;
	if (!handler)
		return -EINVAL;

I don't think it's the last one, because e1000_intr (which is sent in to
request_irq() from e1000) is prototyped/defined. I spun up a patch to spit out
some debugging here which simply inserts some printks (if the only driver which
gets this warning is e1000, then it shouldn't flood your logs) -- basically
narrowing down which error condition is causing the failure. I'm guessing it's
probably the first case, but let's be sure.
