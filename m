From: Oliver Neukum <oliver@neukum.org>
Subject: question on rfkill_suspend
Date: Wed, 16 Apr 2008 10:17:02 +0200
Message-ID: <200804161017.04844.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, IvDoorn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:57874 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbYDPIRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 04:17:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

it seems like rfkill does not guarantee that it won't talk to suspended
devices. Is that true? Should request that arrive for suspended devices
be ignored or postponed?

	Regards
		Oliver

#ifdef CONFIG_PM
static int rfkill_suspend(struct device *dev, pm_message_t state)
{
	struct rfkill *rfkill = to_rfkill(dev);

	if (dev->power.power_state.event != state.event) {
		if (state.event & PM_EVENT_SLEEP) {
			mutex_lock(&rfkill->mutex);

			if (rfkill->state == RFKILL_STATE_ON)
				rfkill->toggle_radio(rfkill->data,
						     RFKILL_STATE_OFF);
