From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: Re: [PATCH v2 2/2] checkpatch: suggest using eth_zero_addr() and
 eth_broadcast_addr()
Date: Tue, 21 Apr 2015 23:44:34 +0200
Message-ID: <5536C4C2.4000001@gmail.com>
References: <1429481816-6664-1-git-send-email-mateusz.kulikowski@gmail.com>	 <1429481816-6664-3-git-send-email-mateusz.kulikowski@gmail.com>	 <1429492384.27863.13.camel@perches.com> <5536B9D2.7030200@gmail.com> <1429651348.31675.12.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: apw@canonical.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429651348.31675.12.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.04.2015 23:22, Joe Perches wrote:
> On Tue, 2015-04-21 at 22:57 +0200, Mateusz Kulikowski wrote:
(...)
>>
>> Perhaps it would be smarter to use (for both patches) $stat instead.
>> This applies also to existing checks (like PREFER_ETHER_ADDR_COPY) 
>> so we can catch calls formatted like
>>
>> memset(very.long.structure->something.something_different42,
>>        0xFF, ETH_ALEN);
> 
> Yes, likely that's true.
> 
> checkpatch couldn't --fix it easily unless it's on a
> single line though.

True, True; If you prefer $line and ability to --fix - I'll use that in v3

> 
> As far as I can tell, there are ~120 of these "memcpy"s
> in the tree, but there aren't any "memset"s like that
> split into 2 or more lines.

Some of them are probably candidates for ether_addr_copy(_unaligned) :)
I'll probably take a look at them once I have both functions available.

Regards,
Mateusz

> 
> Here's a list of the multiple line memcpy(..., ETH_ALEN)
> uses that I found.
> 
> arch/arm/mach-davinci/board-mityomapl138.c:144:		memcpy(soc_info->emac_pdata->mac_addr,
> 			factory_config.mac, ETH_ALEN);
> drivers/staging/rtl8712/rtl8712_recv.c:395:			memcpy(skb_push(sub_skb, ETH_ALEN), pattrib->src,
> 				ETH_ALEN);
> drivers/staging/rtl8712/rtl8712_recv.c:396:			memcpy(skb_push(sub_skb, ETH_ALEN), pattrib->dst,
> 				ETH_ALEN);
> drivers/staging/rtl8712/rtl8712_recv.c:402:			memcpy(skb_push(sub_skb, ETH_ALEN), pattrib->src,
> 				ETH_ALEN);
> drivers/staging/rtl8712/rtl8712_recv.c:403:			memcpy(skb_push(sub_skb, ETH_ALEN), pattrib->dst,
> 				ETH_ALEN);
> drivers/staging/rtl8712/os_intfs.c:398:			memcpy(pnetdev->dev_addr,
> 				padapter->eeprompriv.mac_addr, ETH_ALEN);
> drivers/staging/rtl8712/os_intfs.c:414:			memcpy(padapter->eeprompriv.mac_addr,
> 				pnetdev->dev_addr, ETH_ALEN);
> drivers/staging/rtl8712/rtl871x_ioctl_linux.c:107:	memcpy(wrqu.ap_addr.sa_data, pmlmepriv->cur_network.network.MacAddress,
> 		ETH_ALEN);
> drivers/staging/rtl8712/rtl871x_ioctl_linux.c:838:			memcpy(psecuritypriv->PMKIDList[psecuritypriv->
> 				PMKIDIndex].Bssid, strIssueBssid, ETH_ALEN);
> drivers/staging/rtl8712/rtl871x_xmit.c:489:			memcpy(pwlanhdr->addr1, get_bssid(pmlmepriv),
> 				ETH_ALEN);
> drivers/staging/rtl8712/rtl871x_xmit.c:496:			memcpy(pwlanhdr->addr2, get_bssid(pmlmepriv),
> 				ETH_ALEN);
> drivers/staging/rtl8712/rtl871x_xmit.c:503:			memcpy(pwlanhdr->addr3, get_bssid(pmlmepriv),
> 				ETH_ALEN);
> drivers/staging/rtl8712/rtl871x_xmit.c:507:			memcpy(pwlanhdr->addr3, get_bssid(pmlmepriv),
> 				ETH_ALEN);
> drivers/staging/rtl8192e/rtllib_softmac_wx.c:125:		memcpy(wrqu->ap_addr.sa_data,
> 		       ieee->current_network.bssid, ETH_ALEN);
> drivers/staging/rtl8192e/rtllib_tx.c:697:			memcpy(&header.addr1, ieee->current_network.bssid,
> 			       ETH_ALEN);
> drivers/staging/rtl8192e/rtllib_tx.c:700:				memcpy(&header.addr3,
> 				       ieee->current_network.bssid, ETH_ALEN);
> drivers/staging/rtl8192e/rtllib_tx.c:709:			memcpy(&header.addr3, ieee->current_network.bssid,
> 			       ETH_ALEN);
> drivers/staging/rtl8192e/rtllib_softmac.c:3748:		memcpy(wrqu.ap_addr.sa_data, ieee->current_network.bssid,
> 		       ETH_ALEN);
> drivers/staging/rtl8192u/ieee80211/ieee80211_softmac_wx.c:126:		memcpy(wrqu->ap_addr.sa_data,
> 		       ieee->current_network.bssid, ETH_ALEN);
> drivers/staging/slicoss/slicoss.c:567:			memcpy(adapter->currmacaddr, adapter->macaddr,
> 			       ETH_ALEN);
> drivers/staging/slicoss/slicoss.c:569:			memcpy(adapter->netdev->dev_addr, adapter->currmacaddr,
> 			       ETH_ALEN);
> drivers/staging/rtl8723au/hal/usb_halinit.c:1020:		memcpy(pEEPROM->mac_addr, &hwinfo[EEPROM_MAC_ADDR_8723AU],
> 		       ETH_ALEN);
> drivers/staging/rtl8723au/hal/rtl8723a_cmd.c:327:		memcpy(pwlanhdr->addr1,
> 		       get_my_bssid23a(&pmlmeinfo->network), ETH_ALEN);
> drivers/staging/rtl8723au/hal/rtl8723a_cmd.c:328:		memcpy(pwlanhdr->addr2, myid(&padapter->eeprompriv),
> 		       ETH_ALEN);
> drivers/staging/rtl8723au/hal/rtl8723a_cmd.c:335:		memcpy(pwlanhdr->addr2,
> 		       get_my_bssid23a(&pmlmeinfo->network), ETH_ALEN);
> drivers/staging/rtl8723au/hal/rtl8723a_cmd.c:336:		memcpy(pwlanhdr->addr3, myid(&padapter->eeprompriv),
> 		       ETH_ALEN);
> drivers/staging/rtl8723au/hal/rtl8723a_cmd.c:342:		memcpy(pwlanhdr->addr3,
> 		       get_my_bssid23a(&pmlmeinfo->network), ETH_ALEN);
> drivers/scsi/fcoe/fcoe_ctlr.c:945:			memcpy(fcf->fcf_mac,
> 			       ((struct fip_mac_desc *)desc)->fd_mac,
> drivers/scsi/fcoe/fcoe_ctlr.c:1198:				memcpy(granted_mac,
> 				       ((struct fip_mac_desc *)desc)->fd_mac,
> drivers/scsi/fcoe/fcoe_ctlr.c:1204:				memcpy(sel->fcoe_mac,
> 				       ((struct fip_mac_desc *)desc)->fd_mac,
> drivers/scsi/bnx2fc/bnx2fc_fcoe.c:1187:			memcpy(ctlr->ctl_src_addr, ha->addr,
> 			       ETH_ALEN);
> drivers/net/ethernet/emulex/benet/be_cmds.c:3014:			memcpy(mac, resp->macid_macaddr.mac_addr_id.macaddr,
> 			       ETH_ALEN);
> drivers/net/ethernet/emulex/benet/be_cmds.c:3043:		memcpy(mac, resp->macaddr_list[0].mac_addr_id.macaddr,
> 		       ETH_ALEN);
> drivers/net/ethernet/neterion/vxge/vxge-main.c:4632:		memcpy((u8 *)vdev->vpaths[j].macaddr,
> 				ll_config->device_hw_info.mac_addrs[i],
> drivers/net/ethernet/i825xx/sun3_82586.c:538:			memcpy((char *) mc_cmd->mc_list[i++],
> 			       ha->addr, ETH_ALEN);
> drivers/net/ethernet/intel/e100.c:1600:		memcpy(&cb->u.multi.addr[i++ * ETH_ALEN], &ha->addr,
> 			ETH_ALEN);
> drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c:1169:		memcpy(vfres->vsi_res[i].default_mac_addr,
> 		       vf->default_lan_addr.addr, ETH_ALEN);
> drivers/net/ethernet/intel/i40evf/i40e_common.c:615:			memcpy(hw->mac.perm_addr, vsi_res->default_mac_addr,
> 			       ETH_ALEN);
> drivers/net/ethernet/intel/i40evf/i40e_common.c:616:			memcpy(hw->mac.addr, vsi_res->default_mac_addr,
> 			       ETH_ALEN);
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3522:	memcpy(iscsi_stat->mac_local + MAC_PAD, bp->cnic_eth_dev.iscsi_mac,
> 	       ETH_ALEN);
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c:380:		memcpy(bp->dev->dev_addr,
> 		       bp->acquire_resp.resc.current_mac_addr,
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c:757:			memcpy(req->filters[0].mac, bp->dev->dev_addr,
> 			       ETH_ALEN);
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c:1222:				memcpy(resc->current_mac_addr, bulletin->mac,
> 				       ETH_ALEN);
> drivers/net/ethernet/toshiba/ps3_gelic_wireless.c:1162:		memcpy(wl->bssid, data->ap_addr.sa_data,
> 		       ETH_ALEN);
> drivers/net/ethernet/toshiba/ps3_gelic_wireless.c:1188:		memcpy(data->ap_addr.sa_data, wl->active_bssid,
> 		       ETH_ALEN);
> drivers/net/ethernet/micrel/ksz884x.c:4076:			memcpy(hw->override_addr, DEFAULT_MAC_ADDRESS,
> 			       ETH_ALEN);
> drivers/net/ethernet/micrel/ksz884x.c:7091:			memcpy(dev->dev_addr, hw_priv->hw.override_addr,
> 			       ETH_ALEN);
> drivers/net/ethernet/brocade/bna/bna_tx_rx.c:1152:		memcpy(rxf->ucast_active_mac.addr,
> 			rxf->ucast_pending_mac->addr, ETH_ALEN);
> drivers/net/ethernet/brocade/bna/bnad.c:1865:		memcpy(&mc_list[i * ETH_ALEN], &mc_addr->addr[0],
> 							ETH_ALEN);
> drivers/net/ethernet/brocade/bna/bnad.c:3143:		memcpy(&mac_list[entry * ETH_ALEN],
> 		       &ha->addr[0], ETH_ALEN);
> drivers/net/ethernet/atheros/atlx/atl1.c:3132:		memcpy(adapter->hw.mac_addr, adapter->hw.perm_mac_addr,
> 			ETH_ALEN);
> drivers/net/ethernet/chelsio/cxgb3/t3_hw.c:3726:		memcpy(adapter->port[i]->dev_addr, hw_addr,
> 		       ETH_ALEN);
> drivers/net/ethernet/mellanox/mlx4/mcg.c:847:		memcpy(rule_hw->eth.dst_mac_msk, spec->eth.dst_mac_msk,
> 		       ETH_ALEN);
> drivers/net/ethernet/mellanox/mlx4/mcg.c:849:		memcpy(rule_hw->eth.src_mac_msk, spec->eth.src_mac_msk,
> 		       ETH_ALEN);
> drivers/net/ethernet/ti/cpsw.c:2112:		memcpy(priv_sl2->mac_addr, data->slave_data[1].mac_addr,
> 			ETH_ALEN);
> drivers/net/ethernet/sun/sunvnet.c:1532:		memcpy(&info.mcast_addr[n_addrs * ETH_ALEN],
> 		       m->addr, ETH_ALEN);
> drivers/net/ethernet/sun/sunvnet.c:1557:		memcpy(&info.mcast_addr[n_addrs * ETH_ALEN],
> 		       m->addr, ETH_ALEN);
> drivers/net/vmxnet3/vmxnet3_drv.c:2033:				memcpy(buf + i++ * ETH_ALEN, ha->addr,
> 				       ETH_ALEN);
> drivers/net/wireless/cw1200/txrx.c:1039:		memcpy(&priv->action_frame_sa[0],
> 		       ieee80211_get_SA(frame), ETH_ALEN);
> drivers/net/wireless/cw1200/txrx.c:1051:		memcpy(&priv->action_frame_sa[0],
> 		       ieee80211_get_SA(frame), ETH_ALEN);
> drivers/net/wireless/cw1200/txrx.c:1410:			memcpy(map_link.mac_addr, priv->link_id_db[i].mac,
> 			       ETH_ALEN);
> drivers/net/wireless/cw1200/txrx.c:1448:				memcpy(map_link.mac_addr,
> 				       priv->link_id_db[i].mac,
> drivers/net/wireless/cw1200/sta.c:558:		memcpy(&priv->multicast_filter.macaddrs[count],
> 		       ha->addr, ETH_ALEN);
> drivers/net/wireless/cw1200/sta.c:725:				memcpy(wsm_key->wep_pairwise.peer,
> 				       peer_addr, ETH_ALEN);
> drivers/net/wireless/cw1200/sta.c:741:				memcpy(wsm_key->tkip_pairwise.peer,
> 				       peer_addr, ETH_ALEN);
> drivers/net/wireless/cw1200/sta.c:774:				memcpy(wsm_key->aes_pairwise.peer,
> 				       peer_addr, ETH_ALEN);
> drivers/net/wireless/cw1200/sta.c:796:				memcpy(wsm_key->wapi_pairwise.peer,
> 				       peer_addr, ETH_ALEN);
> drivers/net/wireless/prism54/isl_ioctl.c:2491:		memcpy(priv->ndev->dev_addr,
> 		       &((struct sockaddr *) addr)->sa_data, ETH_ALEN);
> drivers/net/wireless/iwlwifi/dvm/main.c:1317:		memcpy(priv->addresses[1].addr, priv->addresses[0].addr,
> 		       ETH_ALEN);
> drivers/net/wireless/iwlwifi/mvm/mac80211.c:501:		memcpy(mvm->addresses[i].addr, mvm->addresses[i-1].addr,
> 		       ETH_ALEN);
> drivers/net/wireless/iwlwifi/mvm/mac80211.c:1812:		memcpy(&cmd->addr_list[cmd->count * ETH_ALEN],
> 		       addr->addr, ETH_ALEN);
> drivers/net/wireless/iwlwifi/mvm/power.c:508:		memcpy(mvmvif->uapsd_misbehaving_bssid, vif->bss_conf.bssid,
> 		       ETH_ALEN);
> drivers/net/wireless/iwlegacy/common.c:5471:			memcpy(il->staging.bssid_addr, bss_conf->bssid,
> 			       ETH_ALEN);
> drivers/net/wireless/rsi/rsi_91x_mgmt.c:1281:				memcpy(common->mac_addr,
> 				       &msg[offset],
> drivers/net/wireless/rsi/rsi_91x_mgmt.c:1282:				memcpy(&common->fw_ver,
> 				       &msg[offset + ETH_ALEN],
> drivers/net/wireless/wl3501_cs.c:876:				memcpy(this->bssid,
> 				       this->bss_set[i].bssid, ETH_ALEN);
> drivers/net/wireless/ath/ath10k/wmi.c:4128:			memcpy(&bssids->bssid_list[i],
> 			       arg->bssids[i].bssid,
> drivers/net/wireless/ath/wcn36xx/smd.c:1059:	memcpy(&msg_body.bss_params.bssid,
> 	       &orig->bss_params.bssid, ETH_ALEN);
> drivers/net/wireless/ath/wcn36xx/smd.c:1060:	memcpy(&msg_body.bss_params.self_mac_addr,
> 	       &orig->bss_params.self_mac_addr, ETH_ALEN);
> drivers/net/wireless/ipw2x00/ipw2200.c:4517:						memcpy(priv->ieee->bssid,
> 						       priv->bssid, ETH_ALEN);
> drivers/net/wireless/ipw2x00/ipw2200.c:4521:						memcpy(priv->ieee->bssid,
> 						       priv->bssid, ETH_ALEN);
> drivers/net/wireless/ipw2x00/ipw2100.c:4728:		memcpy(cmd.host_command_parameters, priv->net_dev->dev_addr,
> 		       ETH_ALEN);
> drivers/net/wireless/mwl8k.c:3970:	memcpy(&cmd->create_params.peer_mac_addr[0], stream->sta->addr,
> 	       ETH_ALEN);
> drivers/net/wireless/hostap/hostap_80211_tx.c:180:			memcpy(&hdr.addr1, iface->u.wds.remote_addr,
> 			       ETH_ALEN);
> drivers/net/wireless/hostap/hostap_80211_tx.c:195:		memcpy(&hdr.addr1, to_assoc_ap ?
> 		       local->assoc_ap_addr : local->bssid, ETH_ALEN);
> drivers/net/wireless/rtlwifi/cam.c:305:			memcpy(rtlpriv->sec.hwsec_cam_sta_addr[entry_idx],
> 			       sta_addr, ETH_ALEN);
> drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c:3181:			memcpy(&cfg->pmk_list->pmkids.pmkid[i].BSSID,
> 			       &cfg->pmk_list->pmkids.pmkid[i + 1].BSSID,
> drivers/net/wireless/airo.c:3657:			memcpy(&micbuf,
> 				ai->rxfids[0].virtual_host_addr + ETH_ALEN * 2,
> drivers/net/wireless/airo.c:3667:		memcpy(buffer + ETH_ALEN * 2,
> 			ai->rxfids[0].virtual_host_addr + ETH_ALEN * 2 + off,
> drivers/net/wireless/airo.c:7189:			memcpy(address[i].sa_data,
> 			       status_rid.bssid[i], ETH_ALEN);
> drivers/net/wireless/libertas/cmd.c:156:			memcpy(priv->mesh_dev->dev_addr,
> 				priv->current_addr, ETH_ALEN);
> drivers/net/wireless/rndis_wlan.c:1630:			memcpy(mc_addrs + i++ * ETH_ALEN,
> 			       ha->addr, ETH_ALEN);
> drivers/net/wireless/ti/wl1251/main.c:757:			memcpy(fp->mc_list[fp->mc_list_length],
> 					ha->addr, ETH_ALEN);
> drivers/net/wireless/ti/wlcore/main.c:3169:			memcpy(fp->mc_list[fp->mc_list_length],
> 					ha->addr, ETH_ALEN);
> drivers/net/wireless/mwifiex/sta_cmdresp.c:845:		memcpy(priv->curr_bss_params.bss_descriptor.mac_address,
> 		       ibss_coal_resp->bssid, ETH_ALEN);
> drivers/net/wireless/mwifiex/sta_rx.c:251:		memcpy(ta, priv->curr_bss_params.bss_descriptor.mac_address,
> 		       ETH_ALEN);
> drivers/net/wireless/mwifiex/uap_event.c:132:		memcpy(priv->netdev->dev_addr, adapter->event_body + 2,
> 		       ETH_ALEN);
> drivers/net/wireless/mwifiex/cfg80211.c:2881:		memcpy(mef_entry->filter[filt_num].byte_seq, priv->curr_addr,
> 				ETH_ALEN);
> drivers/net/wireless/mwifiex/cfg80211.c:2891:		memcpy(mef_entry->filter[filt_num].byte_seq, priv->curr_addr,
> 				ETH_ALEN);
> drivers/net/wireless/mwifiex/sta_cmd.c:411:		memcpy(cmd->params.mac_addr.mac_addr, priv->curr_addr,
> 		       ETH_ALEN);
> drivers/net/wireless/mwifiex/sta_cmd.c:437:	memcpy(mcast_addr->mac_list, mcast_list->mac_list,
> 	       mcast_list->num_multicast_addr * ETH_ALEN);
> drivers/net/wireless/mwifiex/11n_rxreorder.c:483:	memcpy(add_ba_rsp->peer_mac_addr, cmd_addba_req->peer_mac_addr,
> 	       ETH_ALEN);
> drivers/net/wireless/mwifiex/sta_event.c:118:	memcpy(priv->prev_bssid,
> 	       priv->curr_bss_params.bss_descriptor.mac_address, ETH_ALEN);
> drivers/net/wireless/mwifiex/scan.c:873:			memcpy(bssid_tlv->bssid, user_scan_in->specific_bssid,
> 			       ETH_ALEN);
> drivers/net/wireless/mwifiex/join.c:1092:	memcpy(&adhoc_join->bss_descriptor.bssid,
> 	       &bss_desc->mac_address, ETH_ALEN);
> drivers/net/wireless/mwifiex/join.c:1231:		memcpy(bss_desc->mac_address,
> 		       adhoc_result->bssid, ETH_ALEN);
> drivers/net/wireless/mwifiex/join.c:1390:		memcpy(mac_address,
> 		       priv->curr_bss_params.bss_descriptor.mac_address,
> drivers/net/wireless/libertas_tf/cmd.c:333:	memcpy(cmd.maclist, priv->multicastlist,
> 	       priv->nr_of_multicastmacaddr * ETH_ALEN);
> drivers/net/wireless/libertas_tf/main.c:284:	memcpy(txpd->tx_dest_addr_high, skb->data + sizeof(struct txpd) + 4,
> 		ETH_ALEN);
> drivers/net/usb/lg-vl600.c:197:			memcpy(ethhdr->h_source,
> 					&buf->data[sizeof(*ethhdr) + 0x8],
> drivers/net/usb/lg-vl600.c:198:			memcpy(ethhdr->h_dest,
> 					&buf->data[sizeof(*ethhdr) + 0x12],
> drivers/s390/net/qeth_l3_main.c:1489:		memcpy(card->dev->dev_addr,
> 			cmd->data.create_destroy_addr.unique_id, ETH_ALEN);
> drivers/infiniband/hw/mlx4/main.c:869:		memcpy(mlx4_spec->eth.dst_mac, ib_spec->eth.val.dst_mac,
> 		       ETH_ALEN);
> drivers/infiniband/hw/mlx4/main.c:870:		memcpy(mlx4_spec->eth.dst_mac_msk, ib_spec->eth.mask.dst_mac,
> 		       ETH_ALEN);
> net/ethernet/eth.c:253:	memcpy(((u8 *) hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
> 	       haddr, ETH_ALEN);
> net/mac80211/mlme.c:701:		memcpy(mgmt->u.reassoc_req.current_ap, assoc_data->prev_bssid,
> 		       ETH_ALEN);
> net/mac80211/iface.c:563:		memcpy(dev->dev_addr,
> 		       local->hw.wiphy->perm_addr,
> net/mac80211/iface.c:1582:				memcpy(perm_addr,
> 				       local->hw.wiphy->addresses[i].addr,
> net/wireless/nl80211.c:9033:	memcpy(cfg->dst_mac, nla_data(tb[NL80211_WOWLAN_TCP_DST_MAC]),
> 	       ETH_ALEN);
> net/wireless/wext-spy.c:57:			memcpy(spydata->spy_address[i], address[i].sa_data,
> 			       ETH_ALEN);
> net/bluetooth/bnep/core.c:387:		memcpy(__skb_put(nskb, ETH_ALEN), skb_mac_header(skb),
> 								ETH_ALEN);
> net/bluetooth/bnep/core.c:388:		memcpy(__skb_put(nskb, ETH_ALEN + 2), s->eh.h_source,
> 								ETH_ALEN + 2);
> net/bluetooth/bnep/core.c:392:		memcpy(__skb_put(nskb, ETH_ALEN * 2), skb_mac_header(skb),
> 								ETH_ALEN * 2);
> 
> 
> 
> 
