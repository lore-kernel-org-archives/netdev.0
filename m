From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 05/16] i40e: fix long lines
Date: Fri, 10 Jan 2014 10:02:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D457950@AcuExch.aculab.com>
References: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1389344336-1558-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <1389344869.24222.31.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: 'Joe Perches' <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37913 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752964AbaAJKES convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 05:04:18 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02141-01 for <netdev@vger.kernel.org>;
 Fri, 10 Jan 2014 10:04:16 +0000 (GMT)
In-Reply-To: <1389344869.24222.31.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c
> b/drivers/net/ethernet/intel/i40e/i40e_common.c
> []
> > @@ -681,7 +681,8 @@ aq_add_vsi_exit:
> >   * @cmd_details: pointer to command details structure or NULL
> >   **/
> >  i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
> > -				u16 seid, bool set, struct i40e_asq_cmd_details *cmd_details)
> > +				u16 seid, bool set,
> > +				struct i40e_asq_cmd_details *cmd_details)
> 
> Another way this could be changed is to put the
> return value on a separate line like:
> 
> i40e_status
> i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw, u16 seid, bool set,
> 				    struct i40e_asq_cmd_details *cmd_details)

Personally I prefer that so I can find the definition by grepping
for '^function_name' - but it doesn't seem to be done in any linux
source files.

> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
> b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
> []
> > @@ -93,9 +93,9 @@ i40e_status i40e_aq_set_vsi_broadcast(struct i40e_hw *hw,
> >  				u16 vsi_id, bool set_filter,
> >  				struct i40e_asq_cmd_details *cmd_details);
> >  i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
> > -				u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
> > +		u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
> 
> i40e_status
> i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw, u16 vsi_id, bool set,
> 				    struct i40e_asq_cmd_details *cmd_details);
> 
> etc...
> 
> but once you use extremely long 35+ characters
> function names, 80 columns gets a bit silly too.

Again this only a real problem when the coding stand requires that
continuation lines have the parameters lined up under the '('.
If they are indented by 4 spaces (as many of the BSDs do) then you
do stand a chance of laying out a call in a reasonable number of
vertical lines.

My Actual preferred layout is to exclude tabs, indent by 4 spaces
and double-indent continuation lines.
I'll also start continuation lines (of expressions) with an operator
to make it even clearer they are continuation lines.
When I'm scan-reading code I tend to concentrate on the LHS of each line.
- so that is where the information need to be.

Not that I expect Linux to change!
(Other code bases have much worse layout rules.)

	David
